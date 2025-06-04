output "ecr_repo_url" {
  description = "Repository URL for the ECR repository"
  value = aws_ecr_repository.this.repository_url
}
