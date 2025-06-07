resource "aws_ecr_repository" "this" {
  name                 = "${var.country_environment}-${var.deployment_region}-vlt-subscription-ecr"
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

# Only run this in environments where Docker is available
resource "null_resource" "docker_push" {
  count = var.enable_docker_push ? 1 : 0
  
  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com
      cd images
      docker build -t ${aws_ecr_repository.this.name} .
      docker tag ${aws_ecr_repository.this.name}:latest ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${aws_ecr_repository.this.name}:latest
      docker push ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${aws_ecr_repository.this.name}:latest
    EOT
  }
 
  depends_on = [aws_ecr_repository.this]
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
