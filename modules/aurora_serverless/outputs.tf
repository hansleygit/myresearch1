output "cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value = element(
    concat(
      aws_rds_cluster.aurora_serverless.*.cluster_resource_id,
      [""]
    ),
    0,
  )
}


output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value = "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster:${element(
    concat(
      aws_rds_cluster.aurora_serverless.*.cluster_identifier,
      [""]
    ),
    0,
  )}"
}

output "port" {
  description = "The database port number."
  value       = var.port
}

output "security_group_id" {
  description = "Id of the specific security group to retrieve."
  value = element(
    concat(
      aws_security_group.cluster.*.id,
      [""]
    ),
  0)
}

output "db_name" {
  description = "The database name."
  value       = var.db_name
}