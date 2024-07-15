resource "aws_ecr_repository" "saas_boilerplate" {
  name = var.repository_name

  image_tag_mutability = "MUTABLE"  # Optionally, configure image tag mutability
}
