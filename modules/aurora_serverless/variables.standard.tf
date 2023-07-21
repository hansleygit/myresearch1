# ----------------------------------------------------------------------------------------------------------------------
# Required variables for AWS
# ----------------------------------------------------------------------------------------------------------------------

# variable "aws_region" {
#   description = "The AWS region in which all resources will be created."
#   type        = string
# }

# ----------------------------------------------------------------------------------------------------------------------
# Standard Module Required Variables
# ----------------------------------------------------------------------------------------------------------------------

variable "app_id" {
  description = "AppID of the application (from AppHub)."
  type        = string
}

variable "application_name" {
  description = "The name of the application, whether it be a service, website, api, etc."
  type        = string
}

variable "environment" {
  description = "The environment name in which the infrastructure is located. (e.g. dev, test, beta, prod)"
  type        = string
}

variable "development_team_email" {
  description = "The development team email address that is responsible for this resource(s)."
  type        = string
}

variable "infrastructure_team_email" {
  description = "The infrastructure team email address that is responsible for this resource(s)."
  type        = string
}

variable "infrastructure_engineer_email" {
  description = "The infrastructure engineer email address that is responsible for this resource(s)."
  type        = string
}

variable "app_tags" {
  description = "Extra tags to apply to created resources"
  type        = map(string)
  default     = {}
}

variable "module_source" {
  description = "The source of the terraform module.  Automatically populated by HAL."
  type        = string
  default     = ""
}

variable "module_version" {
  description = "The version of the terraform module.  Automatically populated by HAL."
  type        = string
  default     = ""
}
variable "hal_app_id" {
  description = "ID of the Hal application"
  type        = string
  default     = null
}

# variable "iac_source" {
#   description = "The version control repository (VCR) being used"
#   type        = string
#   default     = null
# }