# VPC and Networking Outputs
output "vpc_id" {
  description = "ID of the existing VPC"
  value       = data.aws_vpc.existing.id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.networking.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.networking.public_subnet_ids
}

# ALB Outputs
output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.alb.alb_dns_name
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = module.alb.alb_arn
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.alb.target_group_arn
}

# Security Outputs
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = module.security.alb_sg_id
}

output "ecs_security_group_id" {
  description = "ID of the ECS security group"
  value       = module.security.ecs_sg_id
}

# ECS task execution role output removed - not needed for infrastructure-only deployment

# ECR Outputs
output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.ecr_repo_url
}

output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = module.ecr.ecr_repo_name
}

# Infrastructure Pipeline Specific Outputs
output "alr_ecr_name" {
  description = "ALR ECR repository name following naming convention"
  value       = module.ecr.ecr_repo_name
}

output "alr_alb_name" {
  description = "ALR ALB name following naming convention"
  value       = module.alb.alb_dns_name
}

# Loop-compatible outputs for developers
output "public_subnet_ids_map" {
  description = "Public subnet IDs in map format for loops"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids_map" {
  description = "Private subnet IDs in map format for loops"
  value       = module.networking.private_subnet_ids
}

output "vpc_link_id" {
  description = "VPC Link ID for API Gateway"
  value       = aws_apigatewayv2_vpc_link.this.id
}