output "cluster_endpoint" {
  description = "The DNS address of the RDS instance"
  value = element(
    concat(
      aws_rds_cluster.cluster_with_encryption_global_primary.*.endpoint,
      aws_rds_cluster.cluster_with_encryption_global_secondary.*.endpoint,
      [""]
    ),
    0,
  )
}

output "reader_endpoint" {
  description = "A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas"
  value = element(
    concat(
      aws_rds_cluster.cluster_with_encryption_global_primary.*.reader_endpoint,
      aws_rds_cluster.cluster_with_encryption_global_secondary.*.reader_endpoint,
      [""]
    ),
    0,
  )
}

output "instance_endpoints" {
  value = aws_rds_cluster_instance.cluster_instances.*.endpoint
}

# The DB Cluster ID or name of the cluster, e.g. "my-aurora-cluster"
output "cluster_id" {
  description = "The DNS address for this instance."
  value = element(
    concat(
      aws_rds_cluster.cluster_with_encryption_global_primary.*.id,
      aws_rds_cluster.cluster_with_encryption_global_secondary.*.id,
      [""]
    ),
    0,
  )
}

# The unique resource ID assigned to the cluster e.g. "cluster-POBCBQUFQC56EBAAWXGFJ77GRU"
# This is useful for allowing database authentication via IAM
output "cluster_resource_id" {
  description = "The RDS Cluster Resource ID"
  value = concat(
    aws_rds_cluster.cluster_with_encryption_global_primary.*.cluster_resource_id,
    aws_rds_cluster.cluster_with_encryption_global_secondary.*.cluster_resource_id
  )
}

# Terraform does not provide an output for the cluster ARN, so we have to build it ourselves
output "cluster_arn" {
  description = "Amazon Resource Name (ARN) of cluster"
  value = "arn:aws:rds:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:cluster:${element(
    concat(
      aws_rds_cluster.cluster_with_encryption_global_primary.*.id,
      aws_rds_cluster.cluster_with_encryption_global_secondary.*.id,
      [""]
    ),
    0,
  )}"
}

output "instance_ids" {
  description = "The Instance identifier."
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