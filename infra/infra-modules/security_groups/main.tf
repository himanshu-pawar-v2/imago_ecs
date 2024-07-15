resource "aws_security_group" "rds" {
  name        = "${var.name_prefix}-rds-sg"
  description = "Security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name_prefix}-rds-sg"
    Environment = var.environment
    Owner = var.owner
  }
}

#### ECS FARGATE SECIRITY GROUP ####
resource "aws_security_group" "ecs_security_group" {
  name        = "${var.name_prefix}-ecs-fargate-sg"
  description = "Security group for ECS tasks and services"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.name_prefix}-ecs-fargate-sg"
    Environment = var.environment
    Owner = var.owner
  }
}

# output "security_group_id" {
#   value = aws_security_group.ecs_security_group.id
# }
