variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "family" {
  description = "The family of the ECS task definition"
  type        = string
}

variable "container_definitions_file" {
  description = "The file containing container definitions"
  type        = string
}

variable "execution_role_arn" {
  description = "The ARN of the execution role"
  type        = string
}

variable "task_role_arn" {
  description = "The ARN of the task role"
  type        = string
}

variable "cpu" {
  description = "The number of cpu units used by the task"
  type        = string
}

variable "memory" {
  description = "The amount of memory (in MiB) used by the task"
  type        = string
}

variable "service_name" {
  description = "The name of the ECS service"
  type        = string
}

variable "desired_count" {
  description = "The number of desired tasks"
  type        = number
}

variable "subnets" {
  description = "The subnets associated with the ECS service"
  type        = list(string)
}

variable "security_groups" {
  description = "The security groups associated with the ECS service"
  type        = list(string)
}
