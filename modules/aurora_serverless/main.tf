
############################### Local Variables ################################

locals {
  module_name                   = "aws-aurora-postgresql-tf:aurora-serverless"
  db_subnet_group_name          = var.aws_db_subnet_group_name == null ? var.name : var.aws_db_subnet_group_name
  db_subnet_group_description   = var.aws_db_subnet_group_description == null ? "Subnet group for the ${var.name} DB" : var.aws_db_subnet_group_description
  db_security_group_name        = var.aws_db_security_group_name == null ? var.name : var.aws_db_security_group_name
  db_security_group_description = var.aws_db_security_group_description == null ? "Security group for the ${var.name} DB" : var.aws_db_security_group_description
  final_snapshot_identifier     = "${var.name}-final-snapshot-${formatdate("MMM-DD-YYYY-HH-mm", timestamp())}"
  tags                          = merge(var.app_tags, local.iac_tags)
}

############################### Data Sources ################################

# Get the current AWS region
data "aws_region" "current" {}

# Get the current AWS account
data "aws_caller_identity" "current" {}


############################### Network and Security resources ################################

resource "aws_db_subnet_group" "cluster" {
  name        = local.db_subnet_group_name
  description = local.db_subnet_group_description
  subnet_ids  = var.subnet_ids
  tags = merge(
    {
      "Name" = "The subnet group for the ${var.name} DB"
    },
    local.tags
  )
}

resource "aws_security_group" "cluster" {
  name        = local.db_security_group_name
  description = local.db_security_group_description
  vpc_id      = var.vpc_id
  tags        = var.custom_tags
}

resource "aws_security_group_rule" "allow_connections_from_cidr_blocks" {
  count       = length(var.allow_connections_from_cidr_blocks) == 0 ? 0 : 1
  type        = "ingress"
  from_port   = var.port
  to_port     = var.port
  protocol    = "tcp"
  cidr_blocks = var.allow_connections_from_cidr_blocks

  security_group_id = aws_security_group.cluster.id
}

resource "aws_security_group_rule" "allow_connections_from_security_group" {
  count                    = length(var.allow_connections_from_security_groups)
  type                     = "ingress"
  from_port                = var.port
  to_port                  = var.port
  protocol                 = "tcp"
  source_security_group_id = element(var.allow_connections_from_security_groups, count.index)

  security_group_id = aws_security_group.cluster.id
}

############################### Aurora Cluster Resource  ################################


resource "aws_rds_cluster" "aurora_serverless" {
  count = var.engine_mode == "serverless" ? 1 : 0

  cluster_identifier = var.name
  port               = var.port

  engine         = var.engine
  engine_version = var.engine_version
  engine_mode    = var.engine_mode

  db_subnet_group_name            = aws_db_subnet_group.cluster.name
  vpc_security_group_ids          = [aws_security_group.cluster.id]
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name

  database_name   = var.db_name
  master_username = var.master_username

  # If the RDS Cluster is being restored from a snapshot, the password entered by the user is ignored.
  master_password = var.snapshot_identifier == null ? var.master_password : null

  preferred_maintenance_window = var.preferred_maintenance_window
  preferred_backup_window      = var.preferred_backup_window
  backup_retention_period      = var.backup_retention_period

  # Due to a bug in Terraform, there is no way to disable the final snapshot in Aurora, so we always create one (which
  # is probably a safe default anyway, but a bit annoying for testing). For more info, see:
  # https://github.com/hashicorp/terraform/issues/6786
  final_snapshot_identifier = local.final_snapshot_identifier

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  snapshot_identifier             = var.snapshot_identifier

  apply_immediately = var.apply_immediately
  storage_encrypted = true
  kms_key_id        = var.kms_key_arn

  iam_database_authentication_enabled = var.iam_database_authentication_enabled

  scaling_configuration {
    auto_pause               = var.scaling_configuration_auto_pause
    max_capacity             = var.scaling_configuration_max_capacity
    min_capacity             = var.scaling_configuration_min_capacity
    seconds_until_auto_pause = var.scaling_configuration_seconds_until_auto_pause
  }

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  iam_roles           = var.iam_roles
  tags                = local.tags
}
