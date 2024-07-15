# output "ecs_cluster_id" {
#   description = "The ID of the ECS cluster"
#   value       = aws_ecs_cluster.this.id
# }

# output "ecs_service_id" {
#   description = "The ID of the ECS service"
#   value       = aws_ecs_service.this.id
# }

output "ecs_cluster_id" {
  description = "The ID of the ECS cluster."
  value       = aws_ecs_cluster.this.id
}

output "ecs_service_name" {
  description = "The name of the ECS service."
  value       = aws_ecs_service.this.name
}

output "ecs_task_definition_arn" {
  description = "The ARN of the ECS task definition."
  value       = aws_ecs_task_definition.this.arn
}

output "ecs_task_execution_role_arn" {
  description = "The ARN of the ECS task execution role."
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "The ARN of the ECS task role."
  value       = aws_iam_role.ecs_task_role.arn
}
