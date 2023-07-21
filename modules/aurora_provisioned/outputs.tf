output "cluster_endpoint" {
  description = "The DNS address of the RDS instance"
  value = element(
    concat(
      aws_rds_cluster.cluster_with_encryption_provisioned.*.endpoint,
      [""]
    ),
    0,
  )
}

output "reader_endpoint" {
  description = "A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas"
  value = element(
    concat(
      aws_rds_cluster.cluster_with_encryption_provisioned.*.reader_endpoint,
      [""]
    ),
    0,
  )
}

output "instance_endpoints" {
  description = "The DNS address for this instance."
  value       = aws_rds_cluster_instance.cluster_instances.*.endpoint
}

# The DB Cluster ID or name of the cluster, e.g. "my-aurora-cluster"
output "cluster_id" {
  description = "The RDS Cluster Identifier"
  value = element(
    concat(
      aws_rds_cluster.cluster_with_encryption_provisioned.*.id,
      [""]
    ),
  0)
}

# Terraform does not provide an output for the cluster ARN, so we have to build it ourselves
output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value = "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster:${element(
    concat(
      aws_rds_cluster.cluster_with_encryption_provisioned.*.cluster_identifier,
      [""]
    ),
    0,
  )}"
}

output "instance_ids" {
  description = "The Instance identifie.r"
  value       = aws_rds_cluster_instance.cluster_instances.*.id
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
output "dbi_resource_id" {
  description = " The region-unique, immutable identifier for the DB instance."
  value       = aws_rds_cluster_instance.cluster_instances.*.dbi_resource_id
}

output "cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value       = aws_rds_cluster.cluster_with_encryption_provisioned.*.cluster_resource_id
}
