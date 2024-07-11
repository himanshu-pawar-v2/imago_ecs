variable "region" {
  description = "AWS region"
}

variable "cluster_name" {
  description = "ECS cluster name"
}

variable "task_family" {
  description = "ECS task definition family"
}

variable "container_definitions" {
  description = "JSON encoded container definitions"
}

variable "cpu" {
  description = "CPU units for the task"
}

variable "memory" {
  description = "Memory for the task"
}

variable "subnets" {
  description = "List of subnets for the ECS task"
  type        = list(string)
}

variable "security_groups" {
  description = "List of security groups for the ECS task"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Whether to assign public IP to the task"
  type        = bool
}

variable "service_name" {
  description = "ECS service name"
}

variable "desired_count" {
  description = "Desired count of ECS tasks"
}

variable "task_execution_role_name" {
  description = "Name of ECS task execution IAM role"
}

variable "task_execution_policy_name" {
  description = "Name of ECS task execution IAM policy attachment"
}

variable "task_execution_policy_arn" {
  description = "ARN of ECS task execution IAM policy"
}
