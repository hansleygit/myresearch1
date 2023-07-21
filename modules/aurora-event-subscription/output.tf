output "oncall_sns_topic_arn" {
  description = "The ARN of the SNS topic for oncall events."
  value       = aws_sns_topic.rds_notify_oncall.arn
}

output "oncall_sns_topic_name" {
  description = "The name of the topic for oncall events. Topic names must be made up of only uppercase and lowercase ASCII letters, numbers, underscores, and hyphens, and must be between 1 and 256 characters long. For a FIFO (first-in-first-out) topic, the name must end with the .fifo suffix. If omitted, Terraform will assign a random, unique name."
  value       = aws_sns_topic.rds_notify_oncall.name
}


output "info_sns_topic_arn" {
  description = "The ARN of the SNS topic for information events."
  value       = aws_sns_topic.rds_notify_info.arn
}

output "info_sns_topic_name" {
  description = "The name of the topic for information events. Topic names must be made up of only uppercase and lowercase ASCII letters, numbers, underscores, and hyphens, and must be between 1 and 256 characters long. For a FIFO (first-in-first-out) topic, the name must end with the .fifo suffix. If omitted, Terraform will assign a random, unique name."
  value       = aws_sns_topic.rds_notify_info.name
}

output "cloudwatch_alarm_name" {
  description = "The descriptive name for the alarm. This name must be unique within the user's AWS account"
  value       = aws_cloudwatch_metric_alarm.cpu_utilization_alarm.alarm_name
}