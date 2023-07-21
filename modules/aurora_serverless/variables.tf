# ------------------------------------------------------------------------------
# MODULE PARAMETERS
# These variables are expected to be passed in by the operator when calling this
# terraform module.
# ------------------------------------------------------------------------------

variable "name" {
  description = "The name used to namespace all resources created by these templates, including the cluster and cluster instances (e.g. drupaldb). Must be unique in this region. Must be a lowercase string."
  type        = string
}

variable "db_name" {
  description = "The name for your database of up to 8 alpha-numeric characters. If you do not provide a name, Amazon RDS will not create a database in the DB cluster you are creating."
  type        = string
  default     = null
}

variable "master_username" {
  description = "The username for the master user."
  type        = string
}

variable "master_password" {
  description = "The password for the master user. If var.snapshot_identifier is non-empty, this value is ignored."
  type        = string
}

variable "vpc_id" {
  description = "The id of the VPC in which this DB should be deployed."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet ids where the database instances should be deployed. In the standard Gruntwork VPC setup, these should be the private persistence subnet ids."
  type        = list(string)
}

variable "allow_connections_from_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges that can connect to this DB. In the standard Gruntwork VPC setup, these should be the CIDR blocks of the private app subnets, plus the private subnets in the mgmt VPC."
  type        = list(string)
}

# ------------------------------------------------------------------------------
# OPTIONAL VARIABLES
# ------------------------------------------------------------------------------
variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0.  Allowed values: 0, 1, 5, 15, 30, 60"
  type        = number
  default     = 0
}

variable "monitoring_role_arn" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Be sure this role exists. It will not be created here. You must specify a MonitoringInterval value other than 0 when you specify a MonitoringRoleARN value that is not empty string."
  type        = string
  default     = null
}


# ------------------------------------------------------------------------------
# DEFINE CONSTANTS
# Generally, these values won't need to be changed.
# ------------------------------------------------------------------------------
variable "port" {
  description = "The port the DB will listen on."
  type        = number
  default     = 5432
}

variable "backup_retention_period" {
  description = "How many days to keep backup snapshots around before cleaning them up"
  type        = number
  default     = null
}

# By default, run backups from 2-3am EST, which is 6-7am UTC
variable "preferred_backup_window" {
  description = "The daily time range during which automated backups are created (e.g. 04:00-09:00). Time zone is UTC. Performance may be degraded while a backup runs."
  type        = string
  default     = "06:00-07:00"
}

# By default, do maintenance from 3-4am EST on Sunday, which is 7-8am UTC. For info on whether DB changes cause
# degraded performance or downtime, see:
# http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.DBInstance.Modifying.html
variable "preferred_maintenance_window" {
  description = "The weekly day and time range during which system maintenance can occur (e.g. wed:04:00-wed:04:30). Time zone is UTC. Performance may be degraded or there may even be a downtime during maintenance windows."
  type        = string
  default     = "sun:07:00-sun:08:00"
}

# By default, only apply changes during the scheduled maintenance window, as certain DB changes cause degraded
# performance or downtime. For more info, see:
# http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.DBInstance.Modifying.html
variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Note that cluster modifications may cause degraded performance or downtime."
  type        = bool
  default     = false
}

# Note: you cannot enable encryption on an existing DB, so you have to enable it for the very first deployment. If you
# already created the DB unencrypted, you'll have to create a new one with encryption enabled and migrate your data to
# it. For more info on RDS encryption, see: http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Overview.Encryption.html
variable "storage_encrypted" {
  description = "Specifies whether the DB cluster uses encryption for data at rest in the underlying storage for the DB, its automated backups, Read Replicas, and snapshots. Uses the default aws/rds key in KMS."
  type        = bool
  default     = true
  validation {
    condition     = var.storage_encrypted != false
    error_message = "Storage must be encrypted for all Databases. Set variable storage_encrypted as true."
  }
}

variable "allow_connections_from_security_groups" {
  description = "Specifies a list of Security Groups to allow connections from."
  type        = list(string)
  default     = []
}

variable "kms_key_arn" {
  description = "The ARN of a KMS key that should be used to encrypt data on disk. Only used if var.storage_encrypted is true. If you leave this null, the default RDS KMS key for the account will be used."
  type        = string
  default     = null
}

variable "iam_database_authentication_enabled" {
  description = "Specifies whether mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled. Disabled by default."
  type        = bool
  default     = false # This only can be enabled on Aurora Provisioned and Global clusters. And it is not applied to Serverless.
}

variable "custom_tags" {
  description = "A map of custom tags to apply to the Aurora RDS Instance and the Security Group created for it. The key is the tag name and the value is the tag value."
  type        = map(string)
  default     = {}
}

variable "snapshot_identifier" {
  description = "This is the field need to be configured when we do a cluster rebuild for iac upgrade. This is the Snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05."
  type        = string
  default     = null
}

variable "enabled_cloudwatch_logs_exports" {
  description = "If non-empty, the Aurora cluster will export the specified logs to Cloudwatch. Must be zero or more of: audit, error, general and slowquery"
  type        = list(string)
  default     = []
}

variable "engine" {
  description = "The name of the database engine to be used for the RDS instance. Must be aurora-postgresql."
  type        = string
  default     = "aurora-postgresql"
  validation {
    condition     = var.engine == "aurora-postgresql"
    error_message = "The engine must be 'aurora-postgresql' to run this aurora postgresql terraform module."
  }
}

variable "engine_version" {
  description = "The version of the engine in var.engine to use."
  type        = string
  default     = null
}

variable "engine_mode" {
  description = "The version of aurora to run - provisioned or serverless."
  type        = string
  default     = "serverless"
  validation {
    condition     = var.engine_mode != "Provisioned" || var.engine_mode != "Global"
    error_message = "The engine_mode should be set to \"serverless\" for aurora-serverless sub-module."
  }
}

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true."
  type        = bool
  default     = null
}

variable "performance_insights_enabled" {
  description = "Specifies whether Performance Insights is enabled or not."
  type        = bool
  default     = false
}

variable "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data."
  type        = string
  default     = null
}

################
## The scaling parameters below ONLY apply to serverless aurora.
## https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.how-it-works.html#aurora-serverless.how-it-works.auto-scaling
## You can specify the minimum and maximum ACU. The minimum Aurora capacity unit is the lowest ACU to which the DB cluster can scale down. The
## maximum Aurora capacity unit is the highest ACU to which the DB cluster can scale up. Based on your settings, Aurora Serverless automatically
## creates scaling rules for thresholds for CPU utilization, connections, and available memory.
##
## The below max/min's are in the ACU's.  A good read on the impacts is available here:
##    https://www.jeremydaly.com/aurora-serverless-the-good-the-bad-and-the-scalable/
#################

variable "scaling_configuration_auto_pause" {
  description = "Whether to enable automatic pause. A DB cluster can be paused only when it's idle (it has no connections). If a DB cluster is paused for more than seven days, the DB cluster might be backed up with a snapshot. In this case, the DB cluster is restored when there is a request to connect to it."
  type        = bool
  default     = true
}

variable "scaling_configuration_max_capacity" {
  description = "The maximum capacity. The maximum capacity must be greater than or equal to the minimum capacity. Valid Aurora PostgreSQL capacity values are 2, 4, 8, 16, 32, 64, 192, and 384."
  type        = number
  default     = 256
}

variable "scaling_configuration_min_capacity" {
  description = "The minimum capacity. The minimum capacity must be lesser than or equal to the maximum capacity. Valid Aurora PostgreSQL capacity values are 2, 4, 8, 16, 32, 64, 192, and 384."
  type        = number
  default     = 2
}

variable "scaling_configuration_seconds_until_auto_pause" {
  description = "The time, in seconds, before an Aurora DB cluster in serverless mode is paused. Valid values are 300 through 86400."
  type        = number
  default     = 300
}

variable "db_cluster_parameter_group_name" {
  description = "A cluster parameter group to associate with the cluster. Parameters in a DB cluster parameter group apply to every DB instance in a DB cluster."
  type        = string
  default     = null
}

variable "db_instance_parameter_group_name" {
  description = "An instance parameter group to associate with the cluster instances. Parameters in a DB parameter group apply to a single DB instance in an Aurora DB cluster."
  type        = string
  default     = null
}

variable "publicly_accessible" {
  description = "If you wish to make your database accessible from the public Internet, set this flag to true (WARNING: NOT RECOMMENDED FOR PRODUCTION USAGE!!). The default is false, which means the database is only accessible from within the VPC, which is much more secure."
  type        = bool
  default     = false
  validation {
    condition     = var.publicly_accessible == false
    error_message = "The database is only accessible from within the VPC, which is much more secure, so this value has to be false on publicly_accessible."
  }
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. Be very careful setting this to true; if you do, and you delete this DB instance, you will not have any backups of the data!"
  type        = bool
  default     = false
}

variable "iam_roles" {
  description = "A List of ARNs for the IAM roles to associate to the RDS Cluster."
  type        = list(string)
  default     = null
}

# ----------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These variables may be optionally passed in by the templates using this module to overwite the defaults.
# ----------------------------------------------------------------------------------------------------------------------

variable "aws_db_subnet_group_name" {
  description = "The name of the aws_db_subnet_group that is created. Defaults to var.name if not specified."
  type        = string
  default     = null
}

variable "aws_db_subnet_group_description" {
  description = "The description of the aws_db_subnet_group that is created. Defaults to 'Subnet group for the var.name DB' if not specified."
  type        = string
  default     = null
}

variable "aws_db_security_group_name" {
  description = "The name of the aws_db_security_group that is created. Defaults to var.name if not specified."
  type        = string
  default     = null
}

variable "aws_db_security_group_description" {
  description = "The description of the aws_db_security_group that is created. Defaults to 'Security group for the var.name DB' if not specified."
  type        = string
  default     = null
}
