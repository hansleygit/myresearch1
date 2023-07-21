
locals {
  module_name                           = "aws-aurora-postgresql-tf:aurora_global"
  db_subnet_group_name                  = var.aws_db_subnet_group_name == null ? var.name : var.aws_db_subnet_group_name
  db_subnet_group_description           = var.aws_db_subnet_group_description == null ? "Subnet group for the ${var.name} DB" : var.aws_db_subnet_group_description
  db_security_group_name                = var.aws_db_security_group_name == null ? var.name : var.aws_db_security_group_name
  db_security_group_description         = var.aws_db_security_group_description == null ? "Security group for the ${var.name} DB" : var.aws_db_security_group_description
  final_snapshot_identifier             = "${var.name}-final-snapshot-${formatdate("MMM-DD-YYYY-HH-mm", timestamp())}"
  performance_insights_kms_key_id       = var.performance_insights_enabled == true ? var.kms_key_arn : null
  performance_insights_retention_period = var.performance_insights_enabled == true ? var.performance_insights_retention_period : null
}

# resource "aws_rds_global_cluster" "global_cluster" {
#   count                     = var.is_primary ? 1 : 0
#   global_cluster_identifier = var.global_cluster_identifier
#   engine                    = var.engine
#   engine_version            = var.engine_version
#   database_name             = var.db_name
# }

# data "aws_rds_global_cluster" "create_initial_global_cluster" {
#   source_db_cluster_identifier  = aws_rds_cluster.cluster_with_encryption_global_primary[0].arn
# }


resource "aws_rds_global_cluster" "global_cluster" {
  count                        = var.is_primary ? 1 : 0
  global_cluster_identifier    = var.global_cluster_identifier
  source_db_cluster_identifier = aws_rds_cluster.cluster_with_encryption_global_primary[0].arn
  force_destroy                = true
  deletion_protection          = var.deletion_protection
  database_name                = var.create_initial_global_cluster || (var.snapshot_identifier != "" && var.snapshot_identifier != null) ? null : var.db_name
  #depends_on = [
  #  aws_rds_cluster.cluster_with_encryption_global_primary
  #]
}

resource "aws_rds_cluster" "cluster_with_encryption_global_primary" {
  count              = var.is_primary ? 1 : 0
  cluster_identifier = var.name
  port               = var.port
  engine             = var.engine
  engine_version     = var.engine_version
  engine_mode        = var.engine_mode

  # Cluster identifier for global databases. 
  #global_cluster_identifier = var.global_cluster_identifier

  # NOTE: Using this DB Cluster to create a Global Cluster, the
  # global_cluster_identifier attribute will become populated and
  # Terraform will begin showing it as a difference. Do not configure:
  # global_cluster_identifier = aws_rds_global_cluster.example.id
  # as it creates a circular reference. Use ignore_changes instead.
  lifecycle {
    ignore_changes = [global_cluster_identifier]
  }

  db_subnet_group_name            = aws_db_subnet_group.cluster.name
  vpc_security_group_ids          = [aws_security_group.cluster.id]
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name
  database_name                   = var.db_name
  master_username                 = var.master_username

  # If the RDS Cluster is being restored from a snapshot, the password entered by the user is ignored.
  master_password              = var.snapshot_identifier == null ? var.master_password : null
  preferred_maintenance_window = var.preferred_maintenance_window
  preferred_backup_window      = var.preferred_backup_window
  backup_retention_period      = var.backup_retention_period
  # Due to a bug in Terraform, there is no way to disable the final snapshot in Aurora, so we always create one (which
  # is probably a safe default anyway, but a bit annoying for testing). For more info, see:
  # https://github.com/hashicorp/terraform/issues/6786
  final_snapshot_identifier           = local.final_snapshot_identifier
  snapshot_identifier                 = var.snapshot_identifier
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  apply_immediately                   = var.apply_immediately
  storage_encrypted                   = true
  kms_key_id                          = var.kms_key_arn
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  deletion_protection                 = var.deletion_protection
  skip_final_snapshot                 = var.skip_final_snapshot
  iam_roles                           = var.iam_roles
  tags                                = var.custom_tags
  depends_on = [
    aws_cloudwatch_log_group.cluster_cloudwatch_log_group
  ]
}

resource "aws_rds_cluster" "cluster_with_encryption_global_secondary" {
  count              = !var.is_primary && var.global_cluster_identifier != null ? 1 : 0
  cluster_identifier = var.name
  port               = var.port
  engine             = var.engine
  engine_version     = var.engine_version
  engine_mode        = var.engine_mode

  # Cluster identifier for global databases.
  global_cluster_identifier = var.global_cluster_identifier

  # Source region for the secondary database cluster in global databases.
  source_region                   = var.source_region
  db_subnet_group_name            = aws_db_subnet_group.cluster.name
  vpc_security_group_ids          = [aws_security_group.cluster.id]
  db_cluster_parameter_group_name = var.db_cluster_parameter_group_name
  preferred_maintenance_window    = var.preferred_maintenance_window
  preferred_backup_window         = var.preferred_backup_window
  backup_retention_period         = var.backup_retention_period


  # Due to a bug in Terraform, there is no way to disable the final snapshot in Aurora, so we always create one (which
  # is probably a safe default anyway, but a bit annoying for testing). For more info, see:
  # https://github.com/hashicorp/terraform/issues/6786
  final_snapshot_identifier           = local.final_snapshot_identifier
  snapshot_identifier                 = var.snapshot_identifier
  enabled_cloudwatch_logs_exports     = var.enabled_cloudwatch_logs_exports
  apply_immediately                   = var.apply_immediately
  storage_encrypted                   = true
  kms_key_id                          = var.kms_key_arn
  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  deletion_protection                 = var.deletion_protection
  skip_final_snapshot                 = var.skip_final_snapshot
  iam_roles                           = var.iam_roles
  tags                                = var.custom_tags
  #enable_global_write_forwarding      = true
  depends_on = [
    aws_cloudwatch_log_group.cluster_cloudwatch_log_group
  ]
}

# Note, since this is no encryption and serverless requires encryption, there's no auto scaling configuration block here.  Also
# why there's no engine mode, as it's only relevant for encrypted systems
# Get the current AWS region
data "aws_region" "current" {}

# Get the current AWS account
data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# CREATE THE AURORA INSTANCES THAT RUN IN THE CLUSTER
# Note that in Terraform, the aws_rds_cluster_instance resource is used *only*
# for Aurora. See aws_db_instance for other types of RDS databases.
# ------------------------------------------------------------------------------

# Optionally create a role that has permissions for enhanced monitoring
# This is only created if var.monitoring_interval and a role isn't explicitily set with
# var.monitoring_role_arn
resource "aws_iam_role" "enhanced_monitoring_role" {
  # The reason we use a count here is to ensure this resource is only created if var.monitoring_interval is set and
  # var.monitoring_role_arn is not provided
  count              = var.monitoring_interval > 0 && var.monitoring_role_arn == null ? 1 : 0
  name               = "${var.name}-monitoring-role"
  assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring_role.json
  tags               = var.custom_tags

  # Workaround for a bug where Terraform sometimes doesn't wait long enough for the IAM role to propagate.
  # https://github.com/hashicorp/terraform/issues/4306
  provisioner "local-exec" {
    command = "echo 'Sleeping for 30 seconds to work around IAM Instance Profile propagation bug in Terraform' && sleep 30"
  }
}

data "aws_iam_policy_document" "enhanced_monitoring_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

# Connect the role to the AWS default policy for enhanced monitoring
resource "aws_iam_role_policy_attachment" "enhanced_monitoring_role_attachment" {
  count      = var.monitoring_interval > 0 && var.monitoring_role_arn == null ? 1 : 0
  depends_on = [aws_iam_role.enhanced_monitoring_role]
  role = element(
    concat(aws_iam_role.enhanced_monitoring_role.*.name, [""]),
    0,
  )
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

data "aws_iam_role" "auto_created_monitoring_role_arn" {
  count = var.monitoring_interval > 0 && var.monitoring_role_arn == null ? 1 : 0
  name  = var.monitoring_interval > 0 ? element(concat(aws_iam_role.enhanced_monitoring_role.*.arn, [""]), 0) : ""
}

resource "aws_rds_cluster_instance" "cluster_instances" {
  count = var.instance_count * (var.engine_mode == "serverless" ? 0 : (var.pilotlight_enabled ? 0 : 1))

  identifier = "${var.name}-${var.aws_region}-${count.index}"
  cluster_identifier = element(
    concat(
      aws_rds_cluster.cluster_with_encryption_global_primary.*.id,
      aws_rds_cluster.cluster_with_encryption_global_secondary.*.id
    ),
    0,
  )
  instance_class     = var.instance_type
  engine             = var.engine
  engine_version     = var.engine_version
  ca_cert_identifier = var.ca_cert_identifier

  # These DBs instances are not publicly accessible. They should live in a private subnet and only be accessible from
  # specific apps.
  publicly_accessible                   = var.publicly_accessible
  db_subnet_group_name                  = aws_db_subnet_group.cluster.name
  db_parameter_group_name               = var.db_instance_parameter_group_name
  tags                                  = var.custom_tags
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                   = var.monitoring_interval == 0 ? null : var.monitoring_role_arn != null ? var.monitoring_role_arn : data.aws_iam_role.auto_created_monitoring_role_arn[0].arn
  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = local.performance_insights_kms_key_id
  performance_insights_retention_period = local.performance_insights_retention_period
  #performance_insights_kms_key_id = var.performance_insights_kms_key_id
  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  lifecycle {
    # Ensure if recreating instances that new ones are added first
    create_before_destroy = true

    # Updates to engine_version will flow from aws_rds_cluster instead (https://github.com/terraform-providers/terraform-provider-aws/issues/9401)
    ignore_changes = [engine_version]
  }

  # Without this line, I consistently receive the following error: aws_rds_cluster.cluster_without_encryption: Error
  # modifying DB Instance xxx: DBInstanceNotFound: DBInstance not found: xxx. However, I am not 100% sure this resolves
  # the issue.
  depends_on = [
    aws_rds_cluster.cluster_with_encryption_global_primary,
    aws_rds_cluster.cluster_with_encryption_global_secondary
  ]
}

# ------------------------------------------------------------------------------
# CREATE THE SUBNET GROUP THAT SPECIFIES IN WHICH SUBNETS TO DEPLOY THE DB INSTANCES
# ------------------------------------------------------------------------------

resource "aws_db_subnet_group" "cluster" {
  name        = local.db_subnet_group_name
  description = local.db_subnet_group_description
  subnet_ids  = var.subnet_ids
  tags = merge(
    {
      "Name" = "The subnet group for the ${var.name} DB"
    },
    var.custom_tags,
  )
}

# ------------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT CONTROLS WHAT TRAFFIC CAN CONNECT TO THE DB
# ------------------------------------------------------------------------------

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
  security_group_id        = aws_security_group.cluster.id
}

# ------------------------------------------------------------------------------
# Explicitly createa cloudwatch log group for log export
# ------------------------------------------------------------------------------


resource "aws_cloudwatch_log_group" "cluster_cloudwatch_log_group" {
  count             = var.engine_mode != "serverless" && length(var.enabled_cloudwatch_logs_exports) != 0 ? 1 : 0
  name              = "/aws/rds/cluster/${var.name}/postgresql"
  retention_in_days = var.retention_in_days
  kms_key_id        = var.kms_key_arn
  tags              = var.custom_tags
}