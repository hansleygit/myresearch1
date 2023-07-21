
locals {
  module_name                           = "aws-aurora-postgresql-tf:aurora-provisioned"
  db_subnet_group_name                  = var.aws_db_subnet_group_name == null ? var.name : var.aws_db_subnet_group_name
  db_subnet_group_description           = var.aws_db_subnet_group_description == null ? "Subnet group for the ${var.name} DB" : var.aws_db_subnet_group_description
  db_security_group_name                = var.aws_db_security_group_name == null ? var.name : var.aws_db_security_group_name
  db_security_group_description         = var.aws_db_security_group_description == null ? "Security group for the ${var.name} DB" : var.aws_db_security_group_description
  final_snapshot_identifier             = "${var.name}-final-snapshot-${formatdate("MMM-DD-YYYY-HH-mm", timestamp())}"
  performance_insights_kms_key_id       = var.performance_insights_enabled == true ? var.kms_key_arn : null
  performance_insights_retention_period = var.performance_insights_enabled == true ? var.performance_insights_retention_period : null
}


resource "aws_rds_cluster" "cluster_with_encryption_provisioned" {
  count = var.engine_mode == "provisioned" && !var.is_primary && var.global_cluster_identifier == null ? 1 : 0

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

  snapshot_identifier = var.snapshot_identifier

  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  apply_immediately = var.apply_immediately
  storage_encrypted = var.storage_encrypted
  kms_key_id        = var.kms_key_arn

  iam_database_authentication_enabled = var.iam_database_authentication_enabled
  deletion_protection                 = var.deletion_protection
  skip_final_snapshot                 = var.skip_final_snapshot
  iam_roles                           = null
  tags                                = var.custom_tags
  depends_on = [
    aws_cloudwatch_log_group.cluster_cloudwatch_log_group
  ]
}

data "aws_region" "current" {}

# Get the current AWS account
data "aws_caller_identity" "current" {}


resource "aws_iam_role" "enhanced_monitoring_role" {
  count = var.monitoring_interval > 0 && var.monitoring_role_arn == null ? 1 : 0

  name               = "${var.name}-monitoring-role"
  assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring_role.json

  provisioner "local-exec" {
    command = "echo 'Sleeping for 30 seconds to work around IAM Instance Profile propagation bug in Terraform' && sleep 30"
  }
  tags = var.custom_tags
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
  count = var.instance_count * (var.engine_mode == "serverless" ? 0 : 1)

  identifier = "${var.name}-${count.index}"
  cluster_identifier = element(
    concat(
      aws_rds_cluster.cluster_with_encryption_provisioned.*.id,
    ),
    0,
  )
  instance_class = var.instance_type

  engine             = var.engine
  engine_version     = var.engine_version
  ca_cert_identifier = var.ca_cert_identifier

  # These DBs instances are not publicly accessible. They should live in a private subnet and only be accessible from
  # specific apps.
  publicly_accessible = var.publicly_accessible

  db_subnet_group_name    = aws_db_subnet_group.cluster.name
  db_parameter_group_name = var.db_instance_parameter_group_name

  tags = var.custom_tags

  monitoring_interval = var.monitoring_interval
  monitoring_role_arn = var.monitoring_interval == 0 ? null : var.monitoring_role_arn != null ? var.monitoring_role_arn : data.aws_iam_role.auto_created_monitoring_role_arn[0].arn

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_kms_key_id       = local.performance_insights_kms_key_id
  performance_insights_retention_period = local.performance_insights_retention_period

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
    aws_rds_cluster.cluster_with_encryption_provisioned
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
    var.custom_tags
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

  security_group_id = aws_security_group.cluster.id
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