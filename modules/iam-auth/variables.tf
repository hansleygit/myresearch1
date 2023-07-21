variable "aws_region" {
  description = "The AWS region in which all resources will be created."
  type        = string
}

variable "aws_account_id" {
  description = "The AWS account to deploy into."
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# Standard Module Required Variables
# ---------------------------------------------------------------------------------------------------------------------

variable "app_id" {
  description = "Core ID of the application."
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
  description = "development_team_email"
  type        = string
}

variable "infrastructure_team_email" {
  description = "infrastructure_team_email"
  type        = string
}

variable "infrastructure_engineer_email" {
  description = "infrastructure_engineer_email"
  type        = string
}


variable "module_source" {
  description = "The source of the terraform module.  Automatically populated by HAL."
  type        = string
  default     = null
}

variable "module_version" {
  description = "The version of the terraform module being used.  Automatically populated by HAL."
  type        = string
  default     = null
}

variable "app_tags" {
  description = "hal app tags"
  type        = map(string)
  default     = {}
}

# ----------------------------------------------------------------------------------------------------------------------
# IAM
# ----------------------------------------------------------------------------------------------------------------------
variable "cluster_resource_id" {
  description = "The region-unique, immutable identifier for the DB cluster."
  type        = list(string)
  default     = []
}

variable "db_user_name" {
  description = "The database user name, could be more than one here."
  #type        = string
  #default     = ""
  type    = list(string)
  default = []
}
# This iam_role_name is needed to be provided by application team
# to decide which iam role is needed to be attached with the IAM DB Authenticaion
variable "iam_role_name" {
  description = "The Name of IAM role"
  type        = string
}
variable "hal_app_id" {
  description = "ID of the Hal application"
  type        = string
  default     = null
}

variable "engine_mode" {
  description = "The version of aurora to run - provisioned or serverless."
  type        = string
  default     = "provisioned"
  validation {
    condition     = var.engine_mode != "Provisioned" || var.engine_mode != "Global"
    error_message = "The engine_mode should be set to \"serverless\" for aurora-serverless sub-module, \"provisioned\" for the aurora-provisioned sub-module and \"provisioned\" + is_secondary = true or is_primary = true for aurora-global submodule."
  }
}
