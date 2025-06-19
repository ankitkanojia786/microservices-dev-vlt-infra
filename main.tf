# Define local variables
locals {
  # Tags for all resources
  tags = {
    "ohi:project"     = var.project_name
    "ohi:application" = var.application_name
    "ohi:module"      = var.module_name
    "ohi:environment" = var.environment
    "ohi:stack-name"  = "${var.environment}-${var.service_name}-tf-init-pipeline"
  }
}

# Networking module: VPC, Subnets, Route Tables, NAT Gateway
module "networking" {
  source               = "./modules/networking"
  region               = var.aws_regions
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.tags
}

# Security module: Security groups, IAM roles
module "security" {
  source         = "./modules/security"
  environment    = var.environment
  vpc_id         = module.networking.vpc_id
  container_port = var.container_port
  tags           = local.tags
}

# ALB module
module "alb" {
  source            = "./modules/alb"
  environment       = var.environment
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
  tags              = local.tags
}

# ECR module: ECR repositories
module "ecr" {
  source      = "./modules/ecr"
  environment = var.environment
}

# ========================================
# AWS PARAMETER STORE - FOR PIPELINE 2
# ========================================

# Store VPC ID
resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.environment}/${var.service_name}/vpc-id"
  type  = "String"
  value = module.networking.vpc_id
  
  tags = local.tags
}

# Store Private Subnet IDs
resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/${var.environment}/${var.service_name}/private-subnet-ids"
  type  = "StringList"
  value = join(",", module.networking.private_subnet_ids)
  
  tags = local.tags
}

# Store Public Subnet IDs
resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/${var.environment}/${var.service_name}/public-subnet-ids"
  type  = "StringList"
  value = join(",", module.networking.public_subnet_ids)
  
  tags = local.tags
}

# Store ALB ARN
resource "aws_ssm_parameter" "alb_arn" {
  name  = "/${var.environment}/${var.service_name}/alb-arn"
  type  = "String"
  value = module.alb.alb_arn
  
  tags = local.tags
}

# Store ALB DNS Name
resource "aws_ssm_parameter" "alb_dns_name" {
  name  = "/${var.environment}/${var.service_name}/alb-dns-name"
  type  = "String"
  value = module.alb.alb_dns_name
  
  tags = local.tags
}

# Store Target Group ARN
resource "aws_ssm_parameter" "target_group_arn" {
  name  = "/${var.environment}/${var.service_name}/target-group-arn"
  type  = "String"
  value = module.alb.target_group_arn
  
  tags = local.tags
}

# Store ECS Security Group ID
resource "aws_ssm_parameter" "ecs_security_group_id" {
  name  = "/${var.environment}/${var.service_name}/ecs-security-group-id"
  type  = "String"
  value = module.security.ecs_sg_id
  
  tags = local.tags
}

# Store ECS Task Execution Role ARN
resource "aws_ssm_parameter" "ecs_task_execution_role_arn" {
  name  = "/${var.environment}/${var.service_name}/ecs-task-execution-role-arn"
  type  = "String"
  value = module.security.ecs_task_execution_role_arn
  
  tags = local.tags
}

# Store ECR Repository URL
resource "aws_ssm_parameter" "ecr_repository_url" {
  name  = "/${var.environment}/${var.service_name}/ecr-repository-url"
  type  = "String"
  value = module.ecr.ecr_repo_url
  
  tags = local.tags
}

# Store ECR Repository Name
resource "aws_ssm_parameter" "ecr_repository_name" {
  name  = "/${var.environment}/${var.service_name}/ecr-repository-name"
  type  = "String"
  value = module.ecr.ecr_repo_name
  
  tags = local.tags
}

# ========================================
# COMMENTED OUT - FOR FUTURE PIPELINE 2
# ========================================

# # Compute module: ECS Cluster
# module "compute" {
#   source             = "./modules/compute"
#   environment        = var.environment
#   vpc_id             = module.networking.vpc_id
#   private_subnet_ids = module.networking.private_subnet_ids
#   tags               = local.tags
# }

# # ECS Service module: Task definition and ECS service
# module "ecs_service" {
#   source             = "./modules/ecs-service"
#   environment        = var.environment
#   cluster_name       = module.compute.ecs_cluster_name
#   service_name       = "${var.environment}-${var.service_name}-ecs-service"
#   task_exec_role_arn = module.security.ecs_task_execution_role_arn
#   ecs_sg_id          = module.security.ecs_sg_id
#   subnet_ids         = module.networking.private_subnet_ids
#   container_port     = var.container_port
#   container_cpu      = var.container_cpu
#   container_memory   = var.container_memory
#   desired_count      = var.desired_count
#   ecr_image          = "${module.ecr.ecr_repo_url}:latest"
#   target_group_arn   = module.alb.target_group_arn
#   tags               = local.tags
# }

# # API Gateway module
# module "api_gateway" {
#   source           = "./modules/api-gateway"
#   environment      = var.environment
#   vpc_id           = module.networking.vpc_id
#   alb_dns_name     = module.alb.alb_dns_name
#   alb_listener_arn = module.alb.http_listener_arn
#   subnet_ids       = module.networking.private_subnet_ids
#   tags             = local.tags
# }

# # Monitoring module
# module "monitoring" {
#   source           = "./modules/monitoring"
#   environment      = var.environment
#   region           = var.aws_regions
#   ecs_cluster_name = module.compute.ecs_cluster_name
#   alert_emails     = var.alert_emails
#   tags             = local.tags
# }