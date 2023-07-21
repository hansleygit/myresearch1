locals {
  module_name      = "aws-aurora-postgresql-tf:aurora-event-subscription"
  prefix_sanitized = lower(var.prefix)
  suffix_sanitized = lower(var.suffix)
  environment      = lower(var.environment)

  prefix = local.prefix_sanitized == "" ? "" : "${local.prefix_sanitized}-"
  suffix = (local.suffix_sanitized == "" || local.suffix_sanitized == null) ? "" : "-${local.suffix_sanitized}"

  full_app_name = "${local.environment}-${var.app_id}-${var.application_name}"
  clusterid     = "rds-${local.prefix}${local.full_app_name}${local.suffix}"

  tags       = merge(var.app_tags, local.iac_tags)
  kms_key_id = data.aws_kms_key.sns_encryption.id
}

data "aws_rds_cluster" "rds-cluster" {
  cluster_identifier = local.clusterid
}

data "aws_kms_key" "sns_encryption" {
  key_id = var.kms_key_arn
}

resource "aws_db_event_subscription" "rds_oncall_event" {
  name      = "${local.clusterid}-oncall-event"
  sns_topic = aws_sns_topic.rds_notify_oncall.arn

  source_type = "db-instance"
  source_ids  = data.aws_rds_cluster.rds-cluster.cluster_members
  event_categories = [
    "availability",
    "deletion",
    "failover",
    "failure",
    "low storage",
    "notification",
    "read replica",
    "recovery",
    "restoration",
  ]

  tags = local.tags
}

resource "aws_sns_topic" "rds_notify_oncall" {
  name              = "${local.clusterid}-notify-oncall"
  tags              = local.tags
  kms_master_key_id = local.kms_key_id
}

resource "aws_sns_topic_subscription" "oncall_notification_topic_subscription" {
  count                  = length(var.info_emails) > 0 ? length(var.info_emails) : 0
  topic_arn              = aws_sns_topic.rds_notify_oncall.arn #var.sns_topic_arn
  protocol               = var.subscription_protocol           #email
  endpoint               = var.oncall_emails[count.index]      #var.endpoint #email address
  endpoint_auto_confirms = var.endpoint_auto_confirms          #default is false

}

resource "aws_db_event_subscription" "rds_info_event" {
  name      = "${local.clusterid}-info-event"
  sns_topic = aws_sns_topic.rds_notify_info.arn

  source_type = "db-instance"
  source_ids  = data.aws_rds_cluster.rds-cluster.cluster_members
  event_categories = [
    "backup",
    "configuration change",
    "creation",
    "maintenance",
    "read replica",

    "recovery",
    "restoration",
  ]
  tags = local.tags
}

resource "aws_sns_topic" "rds_notify_info" {
  name              = "${local.clusterid}-notify-info"
  tags              = local.tags
  kms_master_key_id = local.kms_key_id
}

resource "aws_sns_topic_subscription" "info_notification_topic_subscription" {
  count                  = length(var.info_emails) > 0 ? length(var.info_emails) : 0
  topic_arn              = aws_sns_topic.rds_notify_info.arn #var.sns_topic_arn
  protocol               = var.subscription_protocol         #email
  endpoint               = var.info_emails[count.index]      #var.endpoint #email address
  endpoint_auto_confirms = var.endpoint_auto_confirms        #default is false

}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {

  alarm_name          = "${local.clusterid}-CPU-Utilization-Alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = "300" #seconds
  statistic           = "Maximum"
  threshold           = var.cpu_utilization_threshold
  alarm_description   = "CPU Utilization alarm for RDS"
  actions_enabled     = "true"
  alarm_actions       = [aws_sns_topic.rds_notify_oncall.arn]
  ok_actions          = [aws_sns_topic.rds_notify_oncall.arn]
  dimensions = {
    DBClusterIdentifier = local.clusterid
  }
  tags = local.tags
}