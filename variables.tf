# ----------------------------------------------------------------------------------------------------------------------
# Required variables for AWS
# ----------------------------------------------------------------------------------------------------------------------

variable "aws_region" {
  description = "The AWS region in which all resources will be created."
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account to deploy into."
  type        = string
}


# ----------------------------------------------------------------------------------------------------------------------
# IAM
# ----------------------------------------------------------------------------------------------------------------------

variable "iam_database_authentication_enabled" {
  description = "Specifies whether mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled. Disabled by default."
  type        = bool
  default     = false # This only can be enabled on Aurora Provisioned and Global clusters.
}

# ----------------------------------------------------------------------------------------------------------------------
# Networking
# ----------------------------------------------------------------------------------------------------------------------

variable "vpc_id" {
  description = "The id of the VPC in which this database should be deployed."
  type        = string
}

variable "custom_subnet_name_filter" {
  description = "The module will default to looking for subnets that were created and tagged as vpc_id-private-pers-az* via the aws-vpc-tf VPC module.  If you did not use that module, you can specify a different tag with this variable."
  type        = string
  default     = "*-private-az*" #"${var.vpc_id}-private-az*" #This can be private persistant subnets in case team has not been upgraded to VPC 3.0
}

variable "subnet_ids" {
  description = "A (optional) list of subnet ids where the database instances should be deployed. If you leave this null instances will be deployed in private-persistence subnets."
  type        = list(string)
  default     = null
}

variable "allow_connections_from_cidr_blocks" {
  description = "A list of CIDR-formatted IP address ranges that can connect to this DB. This is not a recommended allow list practice, please consider to use security groups."
  type        = list(string)
  default     = []
}

variable "allow_connections_from_security_groups" {
  description = "Specifies a list of Security Groups to allow connections from."
  type        = list(string)
  default     = []
}

variable "publicly_accessible" {
  description = "As enterprise standard, RDS should not be publicly accessible. The variable currently is locked as false. Only exist to make sure backward compatibility."
  type        = bool
  default     = false
  validation {
    condition     = var.publicly_accessible == false
    error_message = "The database is only accessible from within the VPC, which is much more secure, so this value has to be false on publicly_accessible."
  }
}
# ----------------------------------------------------------------------------------------------------------------------
# Database
# ----------------------------------------------------------------------------------------------------------------------

variable "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true."
  type        = bool
  default     = null
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
  default     = ""
}

variable "engine_mode" {
  description = "The version of aurora to run - provisioned or serverless."
  type        = string
  default     = "provisioned"

  validation {
    condition     = var.engine_mode != "global" || var.engine_mode != "Global"
    error_message = "The engine_mode `global` deprecated. Set engine_mode to `provisioned` for Global clusters."
  }
}

variable "database_name" {
  description = "The name for your database of up to 8 alpha-numeric characters. If you do not provide a name, Amazon RDS will not create a database in the DB cluster you are creating."
  type        = string
  default     = ""
}

variable "master_username" {
  description = "The username for the master user. This should typically be set as the environment variable _TF_master_username so you don't check it into source control."
  type        = string

  validation {
    condition     = var.master_username == "root" || var.master_username == "administrator"
    error_message = "The master_username in Aurora PostgreSQL only allows to be either root or administrator."
  }
}
variable "master_password" {
  description = "The password for the master user. This should typically be set as the environment variable _TF_master_password so you don't check it into source control. The password must be either saved into myvault or in the AWS Secret Manager."
  type        = string
}

variable "port" {
  description = "The port the DB will listen on."
  type        = number
  default     = 5432
}

variable "parameter_family_name" {
  description = "The family of the DB cluster parameter group. Leave blank to use the default parameter group."
  default     = "aurora-postgresql13"
  type        = string
}

# ----------------------------------------------------------------------------------------------------------------------
# Instances
# ----------------------------------------------------------------------------------------------------------------------

variable "instance_count" {
  description = "How many instances to launch. RDS will automatically pick a leader and configure the others as replicas."
  type        = number
  default     = 2
}

variable "instance_type" {
  description = "The instance type to use for the db (For production, we recommend to use db.r5.x)."
  type        = string
  default     = "db.t3.medium"
  # add validation not to use r4 instance types anymore 
  # If you encountered this error on the destroy, just change your instance_type on your terraform.tfvars to any other instance types
  # except of r4, then re-run the destroy to avoid this validation error.
  validation {
    condition     = substr(var.instance_type, 3, 2) != "r4"
    error_message = "The instance type of r4 will be obsoleted by AWS. Please change it to use other instance types."
  }
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Defaults to false"
  type        = bool
  default     = false
}

variable "ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance."
  type        = string
  default     = "rds-ca-rsa2048-g1"
}

# ----------------------------------------------------------------------------------------------------------------------
# Serverless
# https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v1.how-it-works.html#aurora-serverless.how-it-works.auto-scaling 
# You can specify the minimum and maximum ACU. The minimum Aurora capacity unit is the lowest ACU to which the DB cluster can scale down. The
# maximum Aurora capacity unit is the highest ACU to which the DB cluster can scale up. Based on your settings, Aurora Serverless automatically
# creates scaling rules for thresholds for CPU utilization, connections, and available memory.
# ----------------------------------------------------------------------------------------------------------------------

variable "scaling_auto_pause" {
  description = "Whether to enable automatic pause. A DB cluster can be paused only when it's idle (it has no connections). If a DB cluster is paused for more than seven days, the DB cluster might be backed up with a snapshot. In this case, the DB cluster is restored when there is a request to connect to it."
  type        = bool
  default     = true
}

variable "scaling_max_capacity" {
  description = "The maximum capacity. The maximum capacity must be greater than or equal to the minimum capacity. Valid capacity values are 2, 4, 8, 16, 32, 64, 192, and 384."
  type        = number
  default     = 384
}

variable "scaling_min_capacity" {
  description = "The minimum capacity. The minimum capacity must be lesser than or equal to the maximum capacity. Valid capacity values are 2, 4, 8, 16, 32, 64, 192, and 384."
  type        = number
  default     = 2
}

variable "scaling_seconds_until_auto_pause" {
  description = "The time, in seconds, before an Aurora DB cluster in serverless mode is paused. Valid values are 300 through 86400 (24 hours)."
  type        = number
  default     = 300
}

# ----------------------------------------------------------------------------------------------------------------------
# Logging
# ----------------------------------------------------------------------------------------------------------------------

variable "enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: postgresql."
  type        = list(string)
  default     = []
}


variable "retention_in_days" {
  description = "Define the retention period of postgresql log."
  type        = number
  default     = 7
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90], var.retention_in_days)
    error_message = "Cloudwatch log retention period for postgreSQL log should not be longer than 90 days, please use a value in this list [1, 3, 5, 7, 14, 30, 60, 90]."
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# Monitoring
# ----------------------------------------------------------------------------------------------------------------------

variable "backup_retention_period" {
  description = "Set the retention period for auto snapshot, retention period shall be at least 30 days for production and 14 days for non-production."
  type        = number
  default     = null
}

variable "snapshot_identifier" {
  description = "This is the field need to be configured when we do a cluster rebuild for iac upgrade. This is the Snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05."
  type        = string
  default     = null
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. Be very careful setting this to true; if you do, and you delete this DB instance, you will not have any backups of the data!"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Note that cluster modifications may cause degraded performance or downtime."
  type        = bool
  default     = false
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0.  Allowed values: 0, 1, 5, 15, 30, 60"
  type        = number
  default     = 0
}

variable "monitoring_role_arn" {
  description = "Custom role to use for monitoring. By default if left blank a role will be created using the AmazonRDSEnhancedMonitoringRole policy."
  type        = string
  default     = null
}

variable "performance_insights_enabled" {
  description = "Enable performance insights."
  type        = bool
  default     = false
}


variable "performance_insights_retention_period" {
  description = "Amount of time in days to retain Performance Insights data. Valid values are 7, 731 (2 years) or a multiple of 31.Default to 7 day as it is free."
  type        = number
  default     = 7
  validation {
    condition     = contains([7, 731], var.performance_insights_retention_period) || var.performance_insights_retention_period % 31 == 0
    error_message = "Validate value are 7, 731(2 year) or a multiple of 31. Default to 7 as it is the free tier, any other value would generate additional cost."
  }
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
# ----------------------------------------------------------------------------------------------------------------------
# Encryption
# ----------------------------------------------------------------------------------------------------------------------
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

variable "kms_key_arn" {
  description = "The ARN of a KMS key that should be used to encrypt data on disk. Only used if var.storage_encrypted is true. If you leave this blank, the default RDS KMS key for the account will be used."
  type        = string
  default     = null
}

# ----------------------------------------------------------------------------------------------------------------------
# Optional
# ----------------------------------------------------------------------------------------------------------------------

variable "prefix" {
  description = "Add additional prefix to beginning of resource names."
  type        = string
  default     = ""
}

variable "suffix" {
  description = "Add additional suffix to end of resource names."
  type        = string
  default     = ""
}

variable "is_primary" {
  description = "Determines whether to create the global clutser or not. If true creates the global cluster and primary else creates only secondary for global clusters"
  type        = bool
  default     = false
}

variable "source_region" {
  description = "Source region for global secondary cluster"
  type        = string
  default     = null
}

variable "global_cluster_identifier" {
  description = "Global cluster identifier when creating global primary and secondary cluster"
  type        = string
  default     = null
}

# tflint-ignore: terraform_unused_declarations
variable "iam_roles" {
  description = "A List of ARNs for the IAM roles to associate to the RDS Cluster."
  type        = list(string)
  default     = null
}

variable "is_secondary" {
  description = "Determines whether to create the global secondary clutser or not. If true creates secondary for global clusters"
  type        = bool
  default     = false
}


variable "postgres_instance_parameters" {
  description = "customize parameter for aurora instance parameter group."
  type        = list(map(string))
  default     = []
}

variable "default_instance_parameters" {
  description = "default customize parameter for aurora instance parameter group provided automatically for best practices."
  type        = list(map(string))
  default = [{
    name         = "log_statement"
    value        = "none"
    apply_method = "immediate"
  }]
}


variable "postgres_cluster_parameters" {
  description = "customize parameter for aurora cluster parameter group provided by application team."
  type        = list(map(string))
  default     = []
}


# forced default values on cluster parameter group
variable "default_cluster_parameters" {
  description = "default customize parameter for aurora cluster parameter group provided automatically for best practices."
  type        = list(map(string))
  default = [
    {
      name         = "rds.force_ssl"
      value        = 1
      apply_method = "immediate"
    },
    {
      name         = "ssl_min_protocol_version"
      value        = "TLSv1.2"
      apply_method = "immediate"
    },
    {
      name         = "shared_preload_libraries"
      value        = "pg_stat_statements,pg_cron"
      apply_method = "pending-reboot"
    }
  ]
}

# tflint-ignore: terraform_unused_declarations
variable "dbi_resource_id" {
  description = "The region-unique, immutable identifier for the DB instance."
  type        = list(string)
  default     = []
}

variable "db_user_name" {
  description = "The database user name, could be more than one here."
  type        = list(string)
  default     = []
}

variable "pg_iam_features" {
  description = "Map of features which require IAM roles for Aurora postgresql."
  type        = map(string)
  default = {
    "s3Import"   = "False",
    "s3Export"   = "False",
    "Lambda"     = "False",
    "SageMaker"  = "False",
    "Comprehend" = "False"
  }
}

variable "lambda_arn" {
  description = "The ARN of the lambdas that will be exectued through Aurora DB."
  type        = list(string)
  default     = null

}

# This iam_role_name is needed to be provided by application team to decide which iam role would be used to execute its lambda function
# which will connect to its database using IAM DB Authentican token. This is only for PostgreSQL. 
variable "iam_role_name" {
  description = "The Name of IAM role"
  type        = string
  default     = ""
}

# We also need this for global secondary which is using same IAM Role as Global Primary Cluster
# tflint-ignore: terraform_unused_declarations
variable "globalprimary_iam_role_name" {
  description = "The Name of IAM role from Global Primary Cluster"
  type        = string
  default     = ""
}

# need this for global secondary cluster which will use same IAM Role as global primary IAM Role which has been create using Primary module
# This must be provided by user and put it into the secondary terraform.tfvars
# tflint-ignore: terraform_unused_declarations
variable "globalprimary_iam_roles_arn" {
  description = "The ARNs for the IAM roles from Global Primary Cluster."
  type        = list(string)
  default     = null
}

variable "create_initial_global_cluster" {
  description = "Used for converting a provisioned instance to global. If you are deploying this code for the first time, set this to true, otherwise set this to false."
  type        = bool
  default     = false
}

variable "pilotlight_enabled" {
  description = "To setup global database active-passive with a pilot-light disaster recovery approach to have zero reader instance on Secondary cluster."
  type        = bool
  default     = false
}
