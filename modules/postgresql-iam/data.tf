data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["rds.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3ImportExport" {
  count = local.s3Import == true || local.s3Export == true ? 1 : 0
  statement {
    sid    = "1"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetObjectMetaData",
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload",
    ]

    resources = [
      aws_s3_bucket.import_export_data_s3[0].arn,
      "${aws_s3_bucket.import_export_data_s3[0].arn}/*",
    ]
  }

  statement {
    sid    = "2"
    effect = "Allow"

    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:Encrypt",
      "kms:Decrypt",
    ]

    resources = [
      var.kms_key_arn != null ? var.kms_key_arn : "*"
    ]
  }
}

data "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.s3"
  tags = {
    Name = "*private*"
  }
}

data "aws_iam_policy_document" "lambda_policydoc" {
  statement {
    sid       = "1"
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = var.lambda_arn
  }
}

################ Lambda Endpoint Data ####################

data "aws_vpc_endpoint" "lambda" {
  count        = local.Lambda == true ? 1 : 0
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.aws_region}.lambda"
  tags = {
    Name = "com.amazonaws.${var.aws_region}.lambda"
  }
}
