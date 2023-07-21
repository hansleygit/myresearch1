variable "aws_region" {
  description = "The AWS region in which all resources will be created."
  type        = string
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


variable "full_app_name" {
  description = "Application name - appid and environment"
  type        = string
}

variable "kms_key_arn" {
  description = "Kms for encrypting S3 data"
  type        = string
}

variable "cluster_identifier" {
  description = "cluster identifier"
  type        = string
}

variable "vpc_id" {
  description = "VPC id RDS cluster"
  type        = string
}

variable "db_sg_id" {
  description = "Security group id RDS cluster"
  type        = string
}

variable "custom_tags" {
  description = "tags for resources"
}

variable "lambda_arn" {
  description = "The ARN of the lambdas that will be exectued through Aurora DB."
  type        = list(string)
  default     = null
}
variable "default_cluster_parameters" {
  description = "default customize parameter for aurora cluster parameter group provided automatically for best practices."
  type        = list(map(string))
  default = [
    # to enforce encryption of database conenctions using TLS 1.2 per Infosec requirement
    {
      name         = "rds.force_ssl"
      value        = "1"
      apply_method = "immediate"
    },
    # to enforce encryption of database conenctions using TLS 1.2 per Infosec requirement
    {
      name         = "ssl_min_protocol_version"
      value        = "TLSv1.2"
      apply_method = "immediate"
    }
  ]
}
variable "postgres_cluster_parameters" {
  description = "customize parameter for aurora cluster parameter group provided by application team."
  type        = list(map(string))
  default     = []
}

variable "engine_mode" {
  description = "The version of aurora to run - provisioned or serverless.  Note, serverless currently only supports MySQL"
  type        = string
  default     = "provisioned"
  validation {
    condition     = var.engine_mode != "Provisioned" || var.engine_mode != "Global"
    error_message = "The engine_mode should be set to \"serverless\" for aurora-serverless sub-module, \"provisioned\" for the aurora-provisioned sub-module and \"provisioned\" + is_secondary = true or is_primary = true for aurora-global submodule."
  }
}


# variable "postgres_instance_parameters" {
#   description = "customize parameter for aurora instance parameter group provided by application teams."
#   type        = list(map(string))
#   default     = []

# }
# # forced default values on instance parameter group
# variable "default_instance_parameters" {
#   description = "default customize parameter for aurora instance parameter group provided automatically for best practices."
#   type        = list(map(string))
#   default = []
# }
