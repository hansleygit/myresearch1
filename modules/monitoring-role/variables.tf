# ----------------------------------------------------------------------------------------------------------------------
# Required variables for AWS
# ----------------------------------------------------------------------------------------------------------------------

# variable "aws_region" {
#   description = "The AWS region in which all resources will be created."
#   type        = string
# }

# variable "aws_account_id" {
#   description = "The AWS account to deploy into."
#   type        = string
# }

# ----------------------------------------------------------------------------------------------------------------------
# Standard Module Required Variables
# ----------------------------------------------------------------------------------------------------------------------

# variable "app_id" {
#   description = "Core ID of the application."
#   type        = string
# }

# variable "application_name" {
#   description = "The name of the application, whether it be a service, website, api, etc."
#   type        = string
# }

# variable "environment" {
#   description = "The environment name in which the infrastructure is located. (e.g. dev, test, beta, prod)"
#   type        = string
# }

# variable "development_team_email" {
#   description = "The development team email address that is responsible for this resource(s)."
#   type        = string
# }

# variable "infrastructure_team_email" {
#   description = "The infrastructure team email address that is responsible for this resource(s)."
#   type        = string
# }

# variable "infrastructure_engineer_email" {
#   description = "The infrastructure engineer email address that is responsible for this resource(s)."
#   type        = string
# }

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
#   type    = map(string)
#   default = {}
# }

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
  default     = "rds-monitoring"
}
# variable "hal_app_id" {
#   description = "ID of the Hal application"
#   type        = string
#   default     = null
# }