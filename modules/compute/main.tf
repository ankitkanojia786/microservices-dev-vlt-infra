resource "aws_ecs_cluster" "this" {
  name = "${var.environment}-vlt-subscription-microservice-ecs-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = {
    "ohi:project"     = "vlt"
    "ohi:application" = "vlt-mobile"
    "ohi:module"      = "vlt-subscription"
    "ohi:environment" = var.environment
  }
}