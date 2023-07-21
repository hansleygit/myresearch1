variable "parameter_family_name" {
  description = "The family of the DB cluster parameter group. This is required due to we force to use custom parameter group instead of default parameter group."
  default     = "aurora-postgresql12"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
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

variable "postgres_cluster_parameters" {
  description = "customize parameter for aurora cluster parameter group provided by application team."
  type        = list(map(string))
  default     = []
}

# forced default values on cluster parameter group
variable "default_cluster_parameters" {
  description = "default customize parameter for aurora cluster parameter group provided automatically for best practices."
  type        = list(map(string))
  default     = []
}