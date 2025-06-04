# ---------------------
# Infrastructure Outputs
# ---------------------

output "vpc_id" {
  value       = module.networking.vpc_id
  description = "ID of the VPC"
}

output "ecs_cluster_name" {
  value       = module.compute.ecs_cluster_name
  description = "Name of the ECS cluster"
}

output "ecs_service_name" {
  value       = module.ecs_service.service_name
  description = "Name of the ECS service"
}

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "DNS name of the Application Load Balancer"
}

output "ecr_repo_url" {
  value       = module.ecr.ecr_repo_url
  description = "URL of the ECR repository"
}

output "cloudwatch_log_group" {
  value       = module.monitoring.log_group_name
  description = "Name of the CloudWatch log group"
}

output "api_gateway_url" {
  value       = module.api_gateway.api_gateway_url
  description = "URL of the API Gateway"
}

# ---------------------
# Pipeline Outputs
# ---------------------

output "terraform_pipeline_name" {
  value       = module.terraform_pipeline.pipeline_name
  description = "Name of the Terraform pipeline"
}

output "terraform_artifact_bucket" {
  value       = module.terraform_pipeline.artifact_bucket
  description = "Name of the S3 bucket for Terraform artifacts"
}

# ---------------------
# Application Pipeline Outputs
# ---------------------

output "ecr_repository_name" {
  value       = "${var.environment}-vlt-subscription-ecr"
  description = "Name of the ECR repository for the application pipeline"
}

output "task_definition_family" {
  value       = "${var.environment}-vlt-subscription-ecs-task-definitions"
  description = "Family name of the ECS task definition for the application pipeline"
}