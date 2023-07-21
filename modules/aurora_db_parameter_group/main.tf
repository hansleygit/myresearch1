locals {
  module_name = "aws-aurora-postgresql-tf:aurora_db_parameter_group"
  environment = lower(var.environment)

  prefix = (var.prefix == "" || var.prefix == null) ? "" : "${lower(var.prefix)}-"
  suffix = (var.suffix == "" || var.suffix == null) ? "" : "-${lower(var.suffix)}"

  full_app_name = "${local.environment}-${var.app_id}-${var.application_name}"
  resource_name = "rds-${local.prefix}${local.full_app_name}${local.suffix}"
  iam_path      = "/iac/rds/"
  pg_name       = "${local.prefix}${local.full_app_name}${local.suffix}-pg"

  instance_parameter_group = setunion(var.postgres_instance_parameters, var.default_instance_parameters)
  tags                     = merge(var.app_tags, local.iac_tags)
}

resource "aws_db_parameter_group" "selected" {

  name        = local.pg_name
  family      = var.parameter_family_name
  description = "RDS Parameter Group for ${local.resource_name}"

  dynamic "parameter" {
    for_each = local.instance_parameter_group
    content {
      name         = parameter.value["name"]
      value        = parameter.value["value"]
      apply_method = parameter.value["apply_method"]
    }
  }

  tags = local.tags
}

