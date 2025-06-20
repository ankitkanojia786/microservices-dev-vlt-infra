resource "aws_ecr_repository" "this" {
  name                 = "${var.environment}-alr-ecr"
  image_tag_mutability = "MUTABLE"
  
  image_scanning_configuration {
    scan_on_push = true
  }
  
  tags = merge(var.tags, {
    Name = "${var.environment}-alr-ecr"
  })
}