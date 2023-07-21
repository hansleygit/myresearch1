output "role_name" {
  description = "Friendly IAM role name to match."
  value       = aws_iam_role.enhanced_monitoring_role.name
}

output "role_arn" {
  description = "ARN of the IAM role."
  value       = aws_iam_role.enhanced_monitoring_role.arn
}
