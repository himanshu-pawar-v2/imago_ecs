resource "aws_ecs_cluster" "this" {
  name = "my-ecs-cluster"

  tags = {
    Environment = "dev"
    Project     = "MyProject"
  }
}

# Other resources and configurations as needed


resource "aws_ecs_task_definition" "this" {
  family                   = var.family
  container_definitions    = file(var.container_definitions_file)
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn
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
    security_groups = var.security_groups
    assign_public_ip = false
  }
}




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
