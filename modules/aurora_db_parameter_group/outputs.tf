output "name" {
  description = "The name of the DB instance parameter group."
  value       = aws_db_parameter_group.selected.id
}