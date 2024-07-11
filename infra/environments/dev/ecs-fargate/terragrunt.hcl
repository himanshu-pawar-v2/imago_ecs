terraform {
  source = "../../modules/ecs-fargate"
}

inputs = {
  region               = "us-west-2"
  cluster_name         = "v2-boilerplate-ecs-cluster-dev" 
  task_family          = "v2-boilerplate-ecs-task-family-dev"
  container_definitions = <<EOF
[
  {
    "name": "v2-boilerplate-container", 
    "image": "nginx:latest",
    "cpu": 256,
    "memory": 512,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80,
        "protocol": "tcp"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/v2-boilerplate-ecs-service",
        "awslogs-region": "us-west-2",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
EOF
  cpu                  = 1
  memory               = 25
  subnets              = ["subnet-12345678", "subnet-87654321"]
  security_groups      = ["sg-12345678"]
  assign_public_ip     = true
  service_name         = "v2-boilerplate-ecs-service"
  desired_count        = 2
  task_execution_role_name = "ecs-task-execution-role"
  task_execution_policy_name = "ecs-task-execution-policy"
  task_execution_policy_arn = "arn:aws:iam::123456789012:policy/ecs-task-execution-policy"
}

