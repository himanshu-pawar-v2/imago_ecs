# resource "aws_ecs_cluster" "this" {
#   name = "my-ecs-cluster"

#   tags = {
#     Name        = "${var.name_prefix}-ecs-cluster"
#     Environment = var.environment
#     Owner = var.owner
#   }
# }

# # Other resources and configurations as needed


# resource "aws_ecs_task_definition" "this" {
#   family                   = var.family
#   container_definitions    = file(var.container_definitions_file)
#   execution_role_arn       = var.execution_role_arn
#   task_role_arn            = var.task_role_arn
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   cpu                      = var.cpu
#   memory                   = var.memory
# }

# resource "aws_ecs_service" "this" {
#   name            = var.service_name
#   cluster         = aws_ecs_cluster.this.id
#   task_definition = aws_ecs_task_definition.this.arn
#   desired_count   = var.desired_count
#   launch_type     = "FARGATE"
#   network_configuration {
#     subnets         = var.subnets
#     security_groups = var.security_groups
#     assign_public_ip = false
#   }
# }

# resource "aws_ecs_service" "this" {
#   name            = "my-ecs-service"
#   cluster         = aws_ecs_cluster.my_cluster.id
#   task_definition = aws_ecs_task_definition.my_task_definition.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"
#   network_configuration {
#     subnets          = ["subnet-0123456789abcdef0", "subnet-abcdef0123456789"]
#     security_groups  = ["sg-0123456789abcdef0"]
#   }

#   # Other configurations as needed
# }
# module "ecs_security_group" {
#   source               = "../security-group"
#   vpc_id               = var.vpc_id
#   security_group_name  = "ecs-fargate-sg"
# }

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.name_prefix}-ecs-task-execution-role"
    Environment = var.environment
    Owner = var.owner
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.name_prefix}-ecs-task-role"
    Environment = var.environment
    Owner = var.owner
  }
}

resource "aws_ecs_cluster" "this" {
  name = "${var.name_prefix}-ecs-cluster"

  tags = {
    Name        = "${var.name_prefix}-ecs-cluster"
    Environment = var.environment
    Owner = var.owner
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.family
  container_definitions    = file(var.container_definitions_file)
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.subnets
    security_groups = var.ecs_security_group_ids
    assign_public_ip = false
  }
}
