output "backend_repo_url" {
  value = aws_ecr_repository.backend_repo.repository_url
}

output "frontend_repo_url" {
  value = aws_ecr_repository.frontend_repo.repository_url
}
