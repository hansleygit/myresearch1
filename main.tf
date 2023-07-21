locals {
  module_name = "aws-aurora-postgresql-tf"
  environment = lower(var.environment)

  prefix = (var.prefix == "" || var.prefix == null) ? "" : "${lower(var.prefix)}-"
  suffix = (var.suffix == "" || var.suffix == null) ? "" : "-${lower(var.suffix)}"

  full_app_name = "${local.environment}-${var.app_id}-${var.application_name}"
  resource_name = "rds-${local.prefix}${local.full_app_name}${local.suffix}"
  # tflint-ignore: terraform_unused_declarations
  iam_path = "/iac/rds/"
  # tflint-ignore: terraform_unused_declarations
  pg_name = "${local.prefix}${local.full_app_name}${local.suffix}-pg"
  # tflint-ignore: terraform_unused_declarations
  cluster_pg_name           = "${local.prefix}${local.full_app_name}${local.suffix}-cpg"
  backup_retention_period   = (var.backup_retention_period == "" || var.backup_retention_period == null) ? null : var.backup_retention_period
  deletion_protection       = var.deletion_protection == null ? (lower(var.environment) == "prod" ? true : false) : var.deletion_protection
  postgres_ver_number_match = ((floor(tonumber(var.engine_version)) == 10 && tonumber(var.engine_version) >= 10.11) || (floor(tonumber(var.engine_version)) == 11 && tonumber(var.engine_version) >= 11.6) || floor(tonumber(var.engine_version)) > 11) ? true : false
  # tflint-ignore: terraform_unused_declarations
  postgres_ver_supports_s3 = local.postgres_ver_number_match

  global_cluster_identifier = (var.is_primary || (var.global_cluster_identifier == null && var.is_secondary)) ? "global-${var.application_name}-${local.environment}-cluster" : var.global_cluster_identifier
  is_provisioned            = var.engine_mode == "provisioned" && (!var.is_primary && !var.is_secondary) ? true : false

  kms_key_arn         = var.kms_key_arn != null ? data.aws_kms_key.rds_aurora[0].arn : ((local.environment == "prod" || local.environment == "beta") ? "Enter Valid ARN" : null)
  skip_final_snapshot = (local.environment == "prod" || local.environment == "beta") ? false : var.skip_final_snapshot


  burstable = substr(lower(var.instance_type), 3, 1) == "t" ? 1 : 0
  burst_tags = {
    "burstable-instance" = local.burstable
  }

  pilotlight_enabled_calculated    = var.is_primary ? false : var.pilotlight_enabled
  db_instance_parameter_group_name = element(concat(module.aurora_db_parameter_group.*.name, [null]), 0)
  db_cluster_parameter_group_name  = element(concat(module.aurora_cluster_parameter_group.*.name, [null]), 0)
  instance_parameter_group         = setunion(var.postgres_instance_parameters, var.default_instance_parameters)
  cluster_parameter_group          = var.engine_mode == "serverless" ? var.postgres_cluster_parameters : setunion(var.postgres_cluster_parameters, var.default_cluster_parameters)
  parameter_family_name            = var.engine_mode == "serverless" ? "aurora-postgresql11" : var.parameter_family_name
}

data "aws_kms_key" "rds_aurora" {
  count  = var.kms_key_arn != null ? 1 : 0
  key_id = var.kms_key_arn
}

data "aws_vpc" "selected" {
  id = var.vpc_id
}

#changed to use aws_subnets data source due to aws_subnet_ids has been deprecated
#makes this look-up also works for custom_subnet_name_filter
data "aws_subnets" "selected" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
  tags = {

    Name = var.custom_subnet_name_filter == null ? "${var.vpc_id}-private*" : var.custom_subnet_name_filter
  }
}

module "aurora_db_parameter_group" {
  #count  = var.parameter_family_name == null ? 0 : 1 #We don't need this due to we have default value and require to use customized parameter group instead of AWS default parameter group
  source = "./modules/aurora_db_parameter_group"

  app_id           = var.app_id
  application_name = var.application_name
  environment      = var.environment

  development_team_email        = var.development_team_email
  infrastructure_team_email     = var.infrastructure_team_email
  infrastructure_engineer_email = var.infrastructure_engineer_email
  hal_app_id                    = var.hal_app_id

  parameter_family_name        = local.parameter_family_name
  postgres_instance_parameters = local.instance_parameter_group

  tags = merge(var.app_tags, local.iac_tags)
}

module "aurora_cluster_parameter_group" {
  #count  = var.parameter_family_name == null ? 0 : 1
  source = "./modules/aurora_cluster_parameter_group"

  app_id                        = var.app_id
  application_name              = var.application_name
  environment                   = var.environment
  development_team_email        = var.development_team_email
  infrastructure_team_email     = var.infrastructure_team_email
  infrastructure_engineer_email = var.infrastructure_engineer_email
  hal_app_id                    = var.hal_app_id

  parameter_family_name       = local.parameter_family_name
  postgres_cluster_parameters = local.cluster_parameter_group

  tags = merge(var.app_tags, local.iac_tags)
}

module "aurora_provisioned" {

  count  = var.engine_mode == "provisioned" && (!var.is_primary && !var.is_secondary) ? 1 : 0
  source = "./modules/aurora_provisioned"

  name    = local.resource_name
  db_name = var.database_name

  engine         = var.engine
  engine_version = var.engine_version
  engine_mode    = var.engine_mode
  port           = var.port

  master_username = var.master_username
  master_password = var.master_password

  instance_count      = var.instance_count
  instance_type       = var.instance_type
  deletion_protection = local.deletion_protection
  ca_cert_identifier  = var.ca_cert_identifier

  vpc_id = data.aws_vpc.selected.id

  subnet_ids = var.subnet_ids == null ? data.aws_subnets.selected.ids : var.subnet_ids

  allow_connections_from_cidr_blocks     = var.allow_connections_from_cidr_blocks
  allow_connections_from_security_groups = var.allow_connections_from_security_groups

  kms_key_arn                         = local.kms_key_arn
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  backup_retention_period = local.backup_retention_period != null ? var.backup_retention_period : (var.environment == "prod" ? 30 : 14)
  snapshot_identifier     = var.snapshot_identifier
  apply_immediately       = var.apply_immediately

  skip_final_snapshot = local.skip_final_snapshot

  db_instance_parameter_group_name = local.db_instance_parameter_group_name

  db_cluster_parameter_group_name = local.db_cluster_parameter_group_name

  enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports
  retention_in_days                     = var.retention_in_days
  preferred_maintenance_window          = var.preferred_maintenance_window
  preferred_backup_window               = var.preferred_backup_window
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_role_arn
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period
  iam_roles                             = null
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade

  app_id                        = var.app_id
  application_name              = var.application_name
  environment                   = var.environment
  development_team_email        = var.development_team_email
  infrastructure_team_email     = var.infrastructure_team_email
  infrastructure_engineer_email = var.infrastructure_engineer_email
  hal_app_id                    = var.hal_app_id
  custom_tags                   = merge(var.app_tags, local.iac_tags, local.burst_tags)
  depends_on                    = [data.aws_subnets.selected]

}

module "aurora_global" {
  count                                  = var.engine_mode == "provisioned" && (var.is_primary || var.is_secondary) ? 1 : 0
  source                                 = "./modules/aurora_global"
  name                                   = local.resource_name
  db_name                                = var.database_name
  engine                                 = var.engine
  engine_version                         = var.engine_version
  engine_mode                            = var.engine_mode
  port                                   = var.port
  master_username                        = var.master_username
  master_password                        = var.master_password
  instance_count                         = var.instance_count
  instance_type                          = var.instance_type
  deletion_protection                    = local.deletion_protection
  global_cluster_identifier              = local.global_cluster_identifier
  ca_cert_identifier                     = var.ca_cert_identifier
  source_region                          = var.source_region
  aws_region                             = var.aws_region
  is_primary                             = var.is_primary
  vpc_id                                 = data.aws_vpc.selected.id
  subnet_ids                             = var.subnet_ids == null ? data.aws_subnets.selected.ids : var.subnet_ids
  allow_connections_from_cidr_blocks     = var.allow_connections_from_cidr_blocks
  allow_connections_from_security_groups = var.allow_connections_from_security_groups
  kms_key_arn                            = local.kms_key_arn
  iam_database_authentication_enabled    = var.iam_database_authentication_enabled
  backup_retention_period                = local.backup_retention_period != null ? var.backup_retention_period : (var.environment == "prod" ? 30 : 14)
  snapshot_identifier                    = var.snapshot_identifier
  apply_immediately                      = var.apply_immediately
  skip_final_snapshot                    = local.skip_final_snapshot
  db_instance_parameter_group_name       = local.db_instance_parameter_group_name
  db_cluster_parameter_group_name        = local.db_cluster_parameter_group_name
  enabled_cloudwatch_logs_exports        = var.engine_mode == "serverless" ? null : var.enabled_cloudwatch_logs_exports
  retention_in_days                      = var.retention_in_days
  preferred_maintenance_window           = var.preferred_maintenance_window
  preferred_backup_window                = var.preferred_backup_window
  monitoring_interval                    = var.monitoring_interval
  monitoring_role_arn                    = var.monitoring_role_arn
  performance_insights_enabled           = var.performance_insights_enabled
  performance_insights_retention_period  = var.performance_insights_retention_period
  iam_roles                              = null #(var.is_secondary == true) ? var.globalprimary_iam_roles_arn : null #fix global secondary IAM association, primary and secondary is using same IAM role, so need to provide primary IAM role ARN for secondary cluster
  app_id                                 = var.app_id
  application_name                       = var.application_name
  environment                            = var.environment
  development_team_email                 = var.development_team_email
  infrastructure_team_email              = var.infrastructure_team_email
  infrastructure_engineer_email          = var.infrastructure_engineer_email
  pilotlight_enabled                     = local.pilotlight_enabled_calculated
  custom_tags                            = merge(var.app_tags, local.iac_tags)
  create_initial_global_cluster          = var.create_initial_global_cluster
  auto_minor_version_upgrade             = var.auto_minor_version_upgrade
}

module "aurora_serverless" {

  count  = var.engine_mode == "serverless" ? 1 : 0
  source = "./modules/aurora_serverless"

  name    = local.resource_name
  db_name = var.database_name

  engine         = var.engine
  engine_version = var.engine_version
  engine_mode    = var.engine_mode
  port           = var.port

  master_username = var.master_username
  master_password = var.master_password

  deletion_protection = local.deletion_protection

  scaling_configuration_auto_pause               = local.environment == "prod" ? false : var.scaling_auto_pause
  scaling_configuration_max_capacity             = var.scaling_max_capacity
  scaling_configuration_min_capacity             = local.environment == "prod" && var.scaling_min_capacity < 2 ? 2 : var.scaling_min_capacity
  scaling_configuration_seconds_until_auto_pause = var.scaling_seconds_until_auto_pause

  vpc_id                                 = data.aws_vpc.selected.id
  subnet_ids                             = var.subnet_ids == null ? data.aws_subnets.selected.ids : var.subnet_ids
  allow_connections_from_cidr_blocks     = var.allow_connections_from_cidr_blocks
  allow_connections_from_security_groups = var.allow_connections_from_security_groups

  kms_key_arn                         = local.kms_key_arn
  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  backup_retention_period = local.backup_retention_period != null ? var.backup_retention_period : (var.environment == "prod" ? 30 : 14)
  snapshot_identifier     = var.snapshot_identifier
  apply_immediately       = var.apply_immediately

  skip_final_snapshot = local.skip_final_snapshot

  db_instance_parameter_group_name = local.db_instance_parameter_group_name
  db_cluster_parameter_group_name  = local.db_cluster_parameter_group_name

  enabled_cloudwatch_logs_exports = var.engine_mode == "serverless" ? null : var.enabled_cloudwatch_logs_exports

  preferred_maintenance_window = var.preferred_maintenance_window
  preferred_backup_window      = var.preferred_backup_window
  monitoring_interval          = var.monitoring_interval
  monitoring_role_arn          = var.monitoring_role_arn
  performance_insights_enabled = var.performance_insights_enabled #Serverless does not allow performance_insights and default value is false
  iam_roles                    = null

  app_id           = var.app_id
  application_name = var.application_name
  environment      = var.environment

  development_team_email        = var.development_team_email
  infrastructure_team_email     = var.infrastructure_team_email
  infrastructure_engineer_email = var.infrastructure_engineer_email

  custom_tags = merge(var.app_tags, local.iac_tags)
  depends_on  = [data.aws_subnets.selected]
}

##IAM DB Authentication Begin
# tflint-ignore: terraform_naming_convention
module "iam-auth" {
  count                         = var.iam_database_authentication_enabled ? 1 : 0
  source                        = "./modules/iam-auth"
  aws_region                    = var.aws_region
  aws_account_id                = var.aws_account_id
  app_id                        = var.app_id
  application_name              = var.application_name
  environment                   = var.environment
  development_team_email        = var.development_team_email
  infrastructure_team_email     = var.infrastructure_team_email
  infrastructure_engineer_email = var.infrastructure_engineer_email
  cluster_resource_id           = local.is_provisioned ? module.aurora_provisioned[0].cluster_resource_id : module.aurora_global[0].cluster_resource_id
  #cluster_resource_id = local.is_provisioned ? module.aurora_provisioned[0].cluster_resource_id : module.aurora_global.*.cluster_resource_id # need to test to see if it works for global primary/secondary using this code??
  db_user_name  = var.db_user_name
  iam_role_name = var.iam_role_name
  engine_mode   = var.engine_mode == "provisioned" && (var.is_primary || var.is_secondary) ? "global" : var.engine_mode
  depends_on    = [module.aurora_provisioned, module.aurora_global]
}

# tflint-ignore: terraform_naming_convention
module "postgresql-iam" {
  count                         = var.engine_mode != "serverless" ? 1 : 0
  source                        = "./modules/postgresql-iam"
  aws_region                    = var.aws_region
  app_id                        = var.app_id
  application_name              = var.application_name
  environment                   = var.environment
  development_team_email        = var.development_team_email
  infrastructure_team_email     = var.infrastructure_team_email
  infrastructure_engineer_email = var.infrastructure_engineer_email
  pg_iam_features               = var.pg_iam_features
  full_app_name                 = local.full_app_name
  lambda_arn                    = var.pg_iam_features["Lambda"] == "True" ? var.lambda_arn : null
  cluster_identifier            = local.resource_name
  kms_key_arn                   = var.kms_key_arn
  vpc_id                        = data.aws_vpc.selected.id
  db_sg_id                      = local.is_provisioned ? module.aurora_provisioned[0].security_group_id : module.aurora_global[0].security_group_id
  custom_tags                   = merge(var.app_tags, local.iac_tags)
  depends_on                    = [module.aurora_provisioned, module.aurora_global]
  engine_mode                   = var.engine_mode == "provisioned" && (var.is_primary || var.is_secondary) ? "global" : var.engine_mode
}

