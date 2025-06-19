resource "aws_ecr_repository" "this" {
  name                 = "${var.environment}-alr-subscription-microservice-ecr"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = {
    "ohi:project"     = "alr"
    "ohi:application" = "alr-mobile"
    "ohi:module"      = "alr-subscription"
    "ohi:environment" = var.environment
    "ohi:stack-name"  = "${var.environment}-alr-subscription-microservice-tf-init-pipeline"
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name
  
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Remove untagged images after 30 days",
        selection = {
          tagStatus     = "untagged",
          countType     = "sinceImagePushed",
          countUnit     = "days",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}