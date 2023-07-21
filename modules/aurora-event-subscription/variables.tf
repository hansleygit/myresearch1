# variable "aws_region" {
#   description = "The AWS region in which all resources will be created."
# }

# variable "aws_account_id" {
#   description = "The AWS account to deploy into."
# }

# ---------------------------------------------------------------------------------------------------------------------
# Standard Module Required Variables
# ---------------------------------------------------------------------------------------------------------------------

# variable "app_id" {
#   description = "Core ID of the application."
# }

# variable "application_name" {
#   description = "The name of the application, whether it be a service, website, api, etc."
# }

# variable "environment" {
#   description = "The environment name in which the infrastructure is located. (e.g. dev, test, beta, prod)"
# }

variable "info_emails" {
  description = "SNS subscription email"
  type        = list(string)
}

variable "oncall_emails" {
  description = "SNS subscription email"
  type        = list(string)
}


# variable "development_team_email" {
#   description = "development_team_email"
# }

# variable "infrastructure_team_email" {
#   description = "infrastructure_team_email"
# }

# variable "infrastructure_engineer_email" {
#   description = "infrastructure_engineer_email"
# }

variable "cpu_utilization_threshold" {
  description = "This is the threshold value for CPU utilization for cloudwatch metric alarm."
  default     = 75
}

# variable "module_source" {
#   description = "The source of the terraform module.  Automatically populated by HAL."
#   type        = string
#   default     = null
# }

# variable "module_version" {
#   description = "The version of the terraform module being used.  Automatically populated by HAL."
#   type        = string
#   default     = null
# }

# variable "app_tags" {
#   description = "hal app tags"
#   type        = map(string)
#   default     = {}
# }

variable "kms_key_arn" {
  description = "The ARN of a KMS key that should be used to encrypt AWS SNS topic for service events."
  type        = string
}

variable "kms_key_id" {
  description = "KMS Key used to encrypt SNS in transit"
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

# ---------------------------------------------------------------------------------------------------------------------
# Infrastructure Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "subscription_protocol" {
  description = "The protocol to use. The possible values for this are: sqs, sms, lambda, application, https, email"
}

variable "endpoint_auto_confirms" {
  description = "(Optional) Boolean indicating whether the end point is capable of auto confirming subscription e.g., PagerDuty (default is false) If using HTTPS, this must be set to true"
  default     = false
}
# variable "hal_app_id" {
#   description = "ID of the Hal application"
#   type        = string
#   default     = null
# }