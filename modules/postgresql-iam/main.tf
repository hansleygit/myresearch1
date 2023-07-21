locals {
  module_name = "aws-aurora-postgresql-tf:postgresql-iam"
  environment = lower(var.environment)
  s3Import    = var.pg_iam_features["s3Import"] == "True" ? true : false
  s3Export    = var.pg_iam_features["s3Export"] == "True" ? true : false
  Lambda      = var.pg_iam_features["Lambda"] == "True" ? true : false
  SageMaker   = var.pg_iam_features["SageMaker"] == "True" ? true : false
  Comprehend  = var.pg_iam_features["Comprehend"] == "True" ? true : false
  iam_path    = "/iac/rds/"
  #iac_tags   = var.custom_tags
  full_app_name = var.engine_mode == "provisioned" || var.engine_mode == "serverless" ? "${local.environment}-${var.app_id}-${var.application_name}" : "${var.aws_region}-${local.environment}-${var.app_id}-${var.application_name}"
}


resource "aws_iam_role" "s3Import" {

  count              = local.s3Import == true ? 1 : 0
  name               = "${local.full_app_name}-s3Import-role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  path               = local.iam_path
  tags               = var.custom_tags
}

resource "aws_iam_role" "s3Export" {
  count              = local.s3Export == true ? 1 : 0
  name               = "${local.full_app_name}-s3Export-role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  path               = local.iam_path
  tags               = var.custom_tags
}
resource "aws_iam_role" "Lambda" {
  count              = local.Lambda == true ? 1 : 0
  name               = "${local.full_app_name}-Lambda-role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  path               = local.iam_path
  tags               = var.custom_tags
}
resource "aws_iam_role" "SageMaker" {
  count              = local.SageMaker == true ? 1 : 0
  name               = "${local.full_app_name}-SageMaker-role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  path               = local.iam_path
  tags               = var.custom_tags
}
resource "aws_iam_role" "Comprehend" {
  count              = local.Comprehend == true ? 1 : 0
  name               = "${local.full_app_name}-Comprehend-role"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  path               = local.iam_path
  tags               = var.custom_tags
}

resource "time_sleep" "iam_role_propagation_wait" {
  create_duration = "30s"
  depends_on = [
    aws_iam_role.s3Import,
    aws_iam_role.s3Export,
    aws_iam_role.Lambda,
    aws_iam_role.SageMaker,
    aws_iam_role.Comprehend
  ]
}

#################################### S3 ############################################

resource "aws_s3_bucket" "import_export_data_s3" {
  count  = local.s3Import == true || local.s3Export == true ? 1 : 0
  bucket = "${local.full_app_name}-rds-backups"
  tags   = var.custom_tags
  lifecycle {
    ignore_changes = [
      server_side_encryption_configuration
    ]
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "import_export_data_s3_encryption_config" {
  count  = local.s3Import == true || local.s3Export == true ? 1 : 0
  bucket = aws_s3_bucket.import_export_data_s3[0].bucket
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_iam_policy" "s3policy" {
  count  = local.s3Import == true || local.s3Export == true ? 1 : 0
  name   = "policy-s3-${local.full_app_name}"
  path   = local.iam_path
  policy = data.aws_iam_policy_document.s3ImportExport[0].json
  tags   = var.custom_tags
}

resource "aws_iam_role_policy_attachment" "s3Import_policy_attachment" {
  count      = local.s3Import == true ? 1 : 0
  role       = aws_iam_role.s3Import[0].name
  policy_arn = aws_iam_policy.s3policy[0].arn
  depends_on = [
    time_sleep.iam_role_propagation_wait
  ]
}

resource "aws_iam_role_policy_attachment" "s3Export_policy_attachment" {
  count      = local.s3Export == true ? 1 : 0
  role       = aws_iam_role.s3Export[0].name
  policy_arn = aws_iam_policy.s3policy[0].arn
  depends_on = [
    time_sleep.iam_role_propagation_wait
  ]
}

resource "aws_security_group_rule" "outbound_rule_s3" {
  count             = local.s3Import == true || local.s3Export == true ? 1 : 0
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  prefix_list_ids   = [data.aws_vpc_endpoint.s3.prefix_list_id]
  security_group_id = var.db_sg_id
}

#################################### Lambda ###################################


resource "aws_iam_policy" "lambdapolicy" {
  count  = local.Lambda == true ? 1 : 0
  name   = "policy-lambda-${local.full_app_name}"
  path   = local.iam_path
  policy = data.aws_iam_policy_document.lambda_policydoc.json
  tags   = var.custom_tags
}


resource "aws_iam_role_policy_attachment" "lambda" {
  count      = local.Lambda == true ? 1 : 0
  role       = aws_iam_role.Lambda[0].name
  policy_arn = aws_iam_policy.lambdapolicy[0].arn
  depends_on = [
    time_sleep.iam_role_propagation_wait
  ]
}

resource "aws_security_group_rule" "outbound_rule_lambda" {
  count                    = local.Lambda == true ? 1 : 0
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "TCP"
  source_security_group_id = join("", data.aws_vpc_endpoint.lambda[0].security_group_ids)
  security_group_id        = var.db_sg_id
}

####################################################################################


# ------------------------------------------------------------------------------
# CREATE THE IAM ROLE ASSOCIATION FOR POSTGRESQL ENGINE
# ------------------------------------------------------------------------------

resource "aws_rds_cluster_role_association" "postgresql-iam-s3import" {
  count                 = local.s3Import == true ? 1 : 0
  db_cluster_identifier = var.cluster_identifier
  feature_name          = "s3Import"
  role_arn              = aws_iam_role.s3Import[0].arn
  depends_on = [
    aws_iam_role_policy_attachment.s3Import_policy_attachment
  ]
}


resource "aws_rds_cluster_role_association" "postgresql-iam-s3export" {

  count                 = local.s3Export == true ? 1 : 0
  db_cluster_identifier = var.cluster_identifier
  feature_name          = "s3Export"
  role_arn              = aws_iam_role.s3Export[0].arn
  depends_on = [
    aws_rds_cluster_role_association.postgresql-iam-s3import
  ]
}

resource "aws_rds_cluster_role_association" "postgresql-iam-lambda" {

  count                 = local.Lambda == true ? 1 : 0
  db_cluster_identifier = var.cluster_identifier
  feature_name          = "Lambda"
  role_arn              = aws_iam_role.Lambda[0].arn
  depends_on = [
    aws_rds_cluster_role_association.postgresql-iam-s3import,
    aws_rds_cluster_role_association.postgresql-iam-s3export
  ]
}


resource "aws_rds_cluster_role_association" "postgresql-iam-Comprehend" {

  count                 = local.Comprehend == true ? 1 : 0
  db_cluster_identifier = var.cluster_identifier
  feature_name          = "Comprehend"
  role_arn              = aws_iam_role.Comprehend[0].arn
  depends_on = [
    aws_rds_cluster_role_association.postgresql-iam-s3import,
    aws_rds_cluster_role_association.postgresql-iam-s3export,
    aws_rds_cluster_role_association.postgresql-iam-lambda
  ]
}


resource "aws_rds_cluster_role_association" "postgresql-iam-SageMaker" {

  count                 = local.SageMaker == true ? 1 : 0
  db_cluster_identifier = var.cluster_identifier
  feature_name          = "SageMaker"
  role_arn              = aws_iam_role.SageMaker[0].arn
  depends_on = [
    aws_rds_cluster_role_association.postgresql-iam-Comprehend,
    aws_rds_cluster_role_association.postgresql-iam-s3import,
    aws_rds_cluster_role_association.postgresql-iam-s3export,
    aws_rds_cluster_role_association.postgresql-iam-lambda
  ]
}
