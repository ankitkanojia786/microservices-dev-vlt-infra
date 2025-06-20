resource "aws_ecs_cluster" "this" {
  name = "${var.environment}-alr-ecs-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  
  tags = {
    "ohi:project"     = "alr"
    "ohi:application" = "alr-mobile"
    "ohi:module"      = "alr-subscription"
    "ohi:environment" = var.environment
    "ohi:stack-name"  = "${var.environment}-alr-subscription-microservice-tf-init-pipeline"
  }
}