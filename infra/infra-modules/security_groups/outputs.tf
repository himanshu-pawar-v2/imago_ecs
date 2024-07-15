output "vpc_security_group_ids" {
  description = "The ID of the RDS security group."
  value = aws_security_group.rds.id
}

output "security_group_id" {
  description = "The ID of the ECS security group."
  value = aws_security_group.ecs_security_group.id
}
