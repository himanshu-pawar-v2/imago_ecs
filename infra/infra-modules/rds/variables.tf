variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "subnet_ids" {
  description = "The list of subnet IDs"
  type        = list(string)
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "environment" {
  description = "The deployment environment"
  type        = string
}

variable "name_prefix" {
  description = "The name prefix for resources"
  type        = string
}

variable "owner" {
  description = "Devops Engineer name"
  type        = string
}

# variable "vpc_security_group_ids" {
#   type = list(string)
# }

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type        = list(string)
  default     = []
}
