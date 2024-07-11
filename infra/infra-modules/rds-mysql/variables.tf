variable "region" {
  description = "AWS region"
}

variable "db_name" {
  description = "Database name"
}

variable "db_username" {
  description = "Database username"
}

variable "db_password" {
  description = "Database password"
}

variable "allocated_storage" {
  description = "Allocated storage for the RDS instance (in GB)"
  type        = number
}

variable "engine_version" {
  description = "MySQL engine version"
}

variable "instance_class" {
  description = "RDS instance class"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS instance"
  type        = list(string)
}

variable "parameter_group_name" {
  description = "Name of the parameter group for the RDS instance"
}

variable "cidr_blocks" {
  description = "CIDR blocks to allow access to the RDS instance"
  type        = list(string)
}
