resource "aws_ecs_cluster" "this" {
  name = "${var.country_environment}-${var.deployment_region}-vlt-subscription-ecs-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = var.tags
}