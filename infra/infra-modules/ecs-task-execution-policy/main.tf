resource "aws_iam_policy" "task_execution_policy" {
  name        = var.policy_name
  description = "Policy for ECS task execution role"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
      // Add more permissions as needed
    ]
  })
}

resource "aws_iam_policy_attachment" "task_execution_policy_attachment" {
  name       = "task-execution-policy-attachment"
  roles      = [aws_iam_role.task_execution_role.name]
  policy_arn = aws_iam_policy.task_execution_policy.arn
}
