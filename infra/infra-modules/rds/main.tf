resource "aws_db_instance" "postgres" {
  allocated_storage    = 20
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  identifier           = "${var.name_prefix}-rds"
  username             = "ketha" #jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)["username"]
  password             = "ketha12345" #jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)["password"]
  parameter_group_name = "default.postgres16"
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = var.vpc_security_group_ids #[aws_security_group.rds_sg.id]
  skip_final_snapshot  = true
  publicly_accessible  = false
  tags = {
    Name        = "${var.name_prefix}-rds"
    Environment = var.environment
    Owner = var.owner
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids
  tags = {
    Name        = "${var.name_prefix}-db-subnet-group"
    Environment = var.environment
    Owner = var.owner
  }
}

