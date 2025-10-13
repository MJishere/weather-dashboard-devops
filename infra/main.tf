# ECR for Frontend
resource "aws_ecr_repository" "frontend_repo" {
  name                 = "${var.project_name}_frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

#ECR for Backend
resource "aws_ecr_repository" "backend_repo" {
  name                 = "${var.project_name}_backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}