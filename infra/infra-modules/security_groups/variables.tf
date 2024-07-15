variable "region" {
  type        = string
  description = "The AWS region to deploy in"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "allowed_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks allowed to access the RDS instance"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for naming AWS resources"
}

variable "environment" {
  type        = string
  description = "The environment (e.g., dev, prod)"
}

variable "owner" {
  description = "Devops Engineer name"
  type        = string
}
