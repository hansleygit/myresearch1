locals {
  module_name      = "aws-aurora-postgresql-tf:monitoring-role"
  prefix_sanitized = lower(var.prefix)
  suffix_sanitized = lower(var.suffix)
  environment      = lower(var.environment)

  prefix = local.prefix_sanitized == "" ? "" : "${local.prefix_sanitized}-"
  suffix = (local.suffix_sanitized == "" || local.suffix_sanitized == null) ? "" : "-${local.suffix_sanitized}"

  full_app_name = "${local.environment}-${var.app_id}-${var.application_name}"
  resource_name = "role-${local.prefix}${local.full_app_name}${local.suffix}"

}

data "aws_iam_policy" "managed_monitoring_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_iam_role" "enhanced_monitoring_role" {
  name               = local.resource_name
  assume_role_policy = file("${path.module}/files/trust-policy.json")

  tags = merge(var.app_tags, local.iac_tags)

  # Workaround for a bug where Terraform sometimes doesn't wait long enough for the IAM role to propagate.
  # https://github.com/hashicorp/terraform/issues/4306
  provisioner "local-exec" {
    command = "echo 'Sleeping for 30 seconds to work around IAM Instance Profile propagation bug in Terraform' && sleep 30"
  }
}

# Connect the role to the AWS default policy for enhanced monitoring
resource "aws_iam_role_policy_attachment" "enhanced_monitoring_role_attachment" {
  depends_on = [aws_iam_role.enhanced_monitoring_role]

  role       = aws_iam_role.enhanced_monitoring_role.name
  policy_arn = data.aws_iam_policy.managed_monitoring_policy.arn
}

