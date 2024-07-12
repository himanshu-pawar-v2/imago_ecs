include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../terraform-modules/rds"
}

inputs = {
  allocated_storage      = 20
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  db_name                = "mydatabase"
  username               = "admin"
  password               = "password"
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  vpc_security_group_ids = ["sg-0e178f2f1eb92ecda"]
  db_subnet_group_name   = "my-db-subnet-group"
}


