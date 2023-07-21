
locals {
  module_name         = "aws-aurora-postgresql-tf:iam-auth"
  environment         = lower(var.environment)
  full_app_name       = var.engine_mode == "provisioned" || var.engine_mode == "serverless" ? "${local.environment}-${var.app_id}-${var.application_name}" : "${var.aws_region}-${local.environment}-${var.app_id}-${var.application_name}"
  iam_path            = "/iac/rds/"
  cluster_resource_id = var.cluster_resource_id
  db_user_name        = var.db_user_name

  resourceid_username = flatten([
    for id in var.cluster_resource_id : [
      for s in var.db_user_name : {
        cluster_resource_id = id
        db_user_name        = s
      }
    ]
    ]
  )

}

resource "aws_iam_role" "iam-dbauth-role" {
  count              = var.iam_role_name == null || var.iam_role_name == "" ? 1 : 0
  name               = "${local.full_app_name}-dbauth-role"
  assume_role_policy = data.aws_iam_policy_document.iam-dbauth-assume.json
  path               = local.iam_path

  tags = merge(var.app_tags, local.iac_tags)
}

resource "time_sleep" "iam_role_propagation_wait" {
  create_duration = "30s"
  depends_on = [
    aws_iam_role.iam-dbauth-role
  ]
}

#create iam policy for DB Authentication
resource "aws_iam_policy" "iam-dbauth-policy" {
  name   = "policy-iamdbauth-${local.full_app_name}"
  path   = "/"
  policy = data.aws_iam_policy_document.iam-dbauth-document.json
  tags   = merge(var.app_tags, local.iac_tags)
}

data "aws_iam_policy_document" "iam-dbauth-document" {

  statement {
    effect = "Allow"
    actions = [
      "rds-db:connect"
    ]

    resources = [
      for ns in local.resourceid_username :
      "arn:aws:rds-db:${var.aws_region}:${var.aws_account_id}:dbuser:${ns.cluster_resource_id}/${ns.db_user_name}"
    ]
  }
}

data "aws_iam_policy_document" "iam-dbauth-assume" {

  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "rds.amazonaws.com"]
    }
  }
}


#Connect the role to the iam-dbauth-policy
resource "aws_iam_role_policy_attachment" "iam-dbauth-role-attachment" {
  role       = var.iam_role_name == null || var.iam_role_name == "" ? aws_iam_role.iam-dbauth-role[0].name : var.iam_role_name
  policy_arn = aws_iam_policy.iam-dbauth-policy.arn
  depends_on = [
    time_sleep.iam_role_propagation_wait
  ]
}

