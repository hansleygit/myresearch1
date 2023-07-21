output "cluster_id" {
  description = "ID of the cluster"
  value = element(
    concat(
      module.aurora_provisioned[*].cluster_id,
      # module.aurora_serverless[*].cluster_id,
      module.aurora_global[*].cluster_id,
      [""]
    ),
    0,
  )
}

output "cluster_endpoint" {
  description = "Primary endpoint of the cluster"
  value = element(
    concat(
      module.aurora_provisioned[*].cluster_endpoint,
      # module.aurora_serverless[*].cluster_endpoint,
      module.aurora_global[*].cluster_endpoint,
      [""]
    ),
    0,
  )
}

output "cluster_arn" {
  description = "ARN of the cluster"
  value = element(
    concat(
      module.aurora_provisioned[*].cluster_arn,
      #module.aurora_serverless[*].cluster_arn,
      module.aurora_global[*].cluster_arn,
      [""]
    ),
    0,
  )
}

output "reader_endpoint" {
  description = "Endpoint of the read replica"
  value = element(
    concat(
      module.aurora_provisioned[*].reader_endpoint,
      # module.aurora_serverless[*].reader_endpoint,
      module.aurora_global[*].reader_endpoint,
      [""]
    ),
    0,
  )
}

output "instance_endpoints" {
  description = "List of endpoints containing each instance"
  value = element(
    concat(
      [module.aurora_provisioned[*].instance_endpoints],
      # [module.aurora_serverless[*].instance_endpoints],
      [module.aurora_global[*].instance_endpoints],
      [""]
    ),
    0,
  )
}

output "database_name" {
  description = "Primary database name"
  value = element(
    concat(
      module.aurora_provisioned[*].db_name,
      #module.aurora_serverless[*].db_name,
      module.aurora_global[*].db_name,
      [""]
    ),
    0,
  )
}

output "port" {
  description = "Database port"
  value = element(
    concat(
      module.aurora_provisioned[*].port,
      #module.aurora_serverless[*].port,
      module.aurora_global[*].port,
      [""]
    ),
    0,
  )
}

output "security_group_id" {
  description = "Security group attached to the RDS instances"
  value = element(
    concat(
      module.aurora_provisioned[*].security_group_id,
      #module.aurora_serverless[*].security_group_id,
      module.aurora_global[*].security_group_id,
      [""]
    ),
    0,
  )
}

output "dbi_resource_id" {
  description = "Unique resource ID assigned to the instance"
  value = element(
    concat(
      [module.aurora_provisioned[*].dbi_resource_id],
      [module.aurora_global[*].dbi_resource_id],
      [""]
    ),
    0,
  )
  depends_on = [module.aurora_global, module.aurora_provisioned]
}

output "db_user_name" {
  description = "The user you assigned to do IAM DB Auth"
  value = element(
    concat(
      [var.db_user_name],
      [""]
    ),
    0,
  )
}

# output "postgresql-iam-arns" {
#   value = element(
#     concat(
#       module.postgreql-iam[*].postgresql_iam_roles,
#       [""]
#     ),
#     0,
#   )
# }


# output "pilotlight_enabled" {
#   value = var.pilotlight_enabled
# }

output "subnet_ids" {
  description = "Subnet ids that can connect to the db instance."
  value       = data.aws_subnets.selected.ids
}

output "burstable" {
  description = "To identify the memory optimized instances"
  value       = local.burstable
}

output "instance_type" {
  description = "Instance types comprise varying combinations of CPU, memory, storage, and networking capacity and give you the flexibility to choose the appropriate mix of resources for your applications."
  value       = var.instance_type
}

