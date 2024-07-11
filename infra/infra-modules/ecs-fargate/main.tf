provider "aws" {
  region = var.region
}

resource "aws_ecs_cluster" "example" {
  name = var.cluster_name
}

resource "aws_ecs_task_definition" "example" {
  family                   = var.task_family
  container_definitions    = jsonencode(var.container_definitions)
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"

  execution_role_arn = aws_iam_role.task_execution_role.arn
}

resource "aws_ecs_service" "example" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnets
    security_groups = var.security_groups
    assign_public_ip = var.assign_public_ip
  }
}

resource "aws_iam_role" "task_execution_role" {
  name = var.task_execution_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy_attachment" "task_execution_policy" {
  name       = var.task_execution_policy_name
  roles      = [aws_iam_role.task_execution_role.name]
  policy_arn = var.task_execution_policy_arn
}
