variable "region" {
  type        = string
  description = "The AWS region to deploy in"
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
}

variable "public_subnets_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"
}

variable "private_subnets_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
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