output "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.this.id
}

output "ecs_service_id" {
  description = "The ID of the ECS service"
  value       = aws_ecs_service.this.id
}
