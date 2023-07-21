output "postgresql_iam_roles" {
  description = "The ARN of the IAM Role."
  value = {

    "s3Import"   = join("", aws_iam_role.s3Import[*].arn),
    "s3Export"   = join("", aws_iam_role.s3Export[*].arn),
    "Lambda"     = join("", aws_iam_role.Lambda[*].arn),
    "SageMaker"  = join("", aws_iam_role.SageMaker[*].arn),
    "Comprehend" = join("", aws_iam_role.Comprehend[*].arn)

  }


}