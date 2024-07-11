provider "aws" {
  region = var.region
}

resource "aws_db_instance" "example" {
  allocated_storage    = var.allocated_storage
  engine               = "mysql"
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  #name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = var.parameter_group_name
  #subnet_group_name    = aws_db_subnet_group.example.name
}

resource "aws_db_subnet_group" "example" {
  name       = "my-db-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_parameter_group" "example" {
  name        = "my-db-parameter-group"
  family      = "mysql5.7"
  description = "Parameter group for MySQL 5.7"
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}

resource "aws_db_security_group" "example" {
  name        = "my-db-security-group"
  description = "Security group for MySQL database instance"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.cidr_blocks
  }
}

resource "aws_security_group_rule" "egress_mysql" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_db_security_group.example.id
  cidr_blocks       = ["0.0.0.0/0"]
}
