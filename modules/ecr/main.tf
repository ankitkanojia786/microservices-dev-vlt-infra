resource "aws_ecr_repository" "this" {
  name                 = "${var.environment}-vlt-subscription-ecr"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = {
    "ohi:project"     = "vlt"
    "ohi:application" = "vlt-subscription"
    "ohi:module"      = "vlt-subscription-be"
    "ohi:environment" = var.environment
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