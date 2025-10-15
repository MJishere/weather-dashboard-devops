# Frontend ECR repository
output "frontend_repo_name" {
  value       = aws_ecr_repository.frontend_repo.name
  description = "Name of the frontend ECR repository"
}

output "frontend_repo_id" {
  value       = aws_ecr_repository.frontend_repo.id
  description = "ID of the frontend ECR repository"
}

# Backend ECR repository
output "backend_repo_name" {
  value       = aws_ecr_repository.backend_repo.name
  description = "Name of the backend ECR repository"
}

output "backend_repo_id" {
  value       = aws_ecr_repository.backend_repo.id
  description = "ID of the backend ECR repository"
}
