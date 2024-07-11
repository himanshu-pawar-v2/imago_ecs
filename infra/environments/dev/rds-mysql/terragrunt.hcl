terraform {
  source = "../../modules/rds-mysql"
}

inputs = {
  region               = "us-east-1"
  db_name              = "mydatabase"
  db_username          = "admin"
  db_password          = "password"
  allocated_storage    = 20
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  subnet_ids           = ["subnet-12345678", "subnet-87654321"]
  parameter_group_name = "my-db-parameter-group"
  cidr_blocks          = ["0.0.0.0/0"]
}

