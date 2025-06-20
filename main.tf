# Define local variables
locals {
  # Extract country and region from environment (e.g., usdev-usw2 -> usdev, usw2)
  country_env = split("-", var.environment)[0]
  aws_region_short = split("-", var.environment)[1]
  aws_region_full = var.region_mapping[split("-", var.environment)[1]]
  
  # Tags for all resources following Voltron Cloud standards
  tags = {
    "ohi:project"     = var.project_name
    "ohi:application" = var.application_name
    "ohi:module"      = var.module_name
    "ohi:environment" = var.environment
    "ohi:stack-name"  = "${var.environment}-${var.project_name}-infra-pipeline-stack"
  }

  # Parameter Store values for Application Pipeline (Pipeline 2)
  parameter_store_values = {
    vpc_id                      = aws_vpc.main.id
    public_subnet_ids           = { for k, v in module.networking.public_subnet_ids : k => v }
    private_subnet_ids          = { for k, v in module.networking.private_subnet_ids : k => v }
    alb_arn                     = module.alb.alb_arn
    alb_dns_name                = module.alb.alb_dns_name
    target_group_arn            = module.alb.target_group_arn
    ecs_security_group_id       = module.security.ecs_sg_id
    ecs_task_execution_role_arn = module.security.ecs_task_execution_role_arn
    ecr_repository_url          = module.ecr.ecr_repo_url
    ecr_repository_arn          = module.ecr.ecr_repo_arn
    ecr_repository_name         = module.ecr.ecr_repo_name
    vpc_link_id                 = aws_apigatewayv2_vpc_link.this.id
  }
}

# Create VPC for testing (in production, this would be existing)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = merge(local.tags, {
    Name = "${var.environment}-vpc"
  })
}

# Reference the created VPC
data "aws_vpc" "existing" {
  id = aws_vpc.main.id
}

# Networking module: Subnets, Route Tables, NAT Gateway (in existing VPC)
module "networking" {
  source               = "./modules/networking"
  region               = local.aws_region_full
  environment          = var.environment
  vpc_id               = aws_vpc.main.id
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.tags
}

# Security module: Security groups, IAM roles
module "security" {
  source         = "./modules/security"
  environment    = var.environment
  vpc_id         = aws_vpc.main.id
  container_port = var.container_port
  tags           = local.tags
}

# ALB module - Named as per requirement: <country+env>-<aws-region>-<project>-alb
module "alb" {
  source               = "./modules/alb"
  environment          = var.environment
  country_environment  = local.country_env
  deployment_region    = local.aws_region_short
  vpc_id               = aws_vpc.main.id
  public_subnet_ids    = module.networking.public_subnet_ids
  alb_sg_id            = module.security.alb_sg_id
  tags                 = local.tags
}

# ECR module - Named as per requirement: <country+env>-<aws-region>-<project>-ecr
module "ecr" {
  source      = "./modules/ecr"
  environment = var.environment
  tags        = local.tags
}

# VPC Link for API Gateway
resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "${var.environment}-alr-vpc-link"
  security_group_ids = []
  subnet_ids         = module.networking.private_subnet_ids
  
  tags = local.tags
}



# ========================================
# AWS PARAMETER STORE - FOR PIPELINE 2 (Using for expressions)
# ========================================

# Store VPC ID
resource "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.environment}/${var.module_name}/vpc-id"
  type  = "String"
  value = local.parameter_store_values.vpc_id
  
  tags = local.tags
}

# Store Public Subnet IDs using for expression
resource "aws_ssm_parameter" "public_subnet_ids" {
  for_each = local.parameter_store_values.public_subnet_ids
  
  name  = "/${var.environment}/${var.module_name}/public-subnet-${each.key}"
  type  = "String"
  value = each.value
  
  tags = merge(local.tags, {
    "SubnetIndex" = each.key
    "SubnetType"  = "public"
  })
}

# Store Private Subnet IDs using for expression
resource "aws_ssm_parameter" "private_subnet_ids" {
  for_each = local.parameter_store_values.private_subnet_ids
  
  name  = "/${var.environment}/${var.module_name}/private-subnet-${each.key}"
  type  = "String"
  value = each.value
  
  tags = merge(local.tags, {
    "SubnetIndex" = each.key
    "SubnetType"  = "private"
  })
}

# Store ALB details
resource "aws_ssm_parameter" "alb_arn" {
  name  = "/${var.environment}/${var.module_name}/alb-arn"
  type  = "String"
  value = local.parameter_store_values.alb_arn
  
  tags = local.tags
}

resource "aws_ssm_parameter" "alb_dns_name" {
  name  = "/${var.environment}/${var.module_name}/alb-dns-name"
  type  = "String"
  value = local.parameter_store_values.alb_dns_name
  
  tags = local.tags
}

resource "aws_ssm_parameter" "target_group_arn" {
  name  = "/${var.environment}/${var.module_name}/target-group-arn"
  type  = "String"
  value = local.parameter_store_values.target_group_arn
  
  tags = local.tags
}

# Store Security Group ID
resource "aws_ssm_parameter" "ecs_security_group_id" {
  name  = "/${var.environment}/${var.module_name}/ecs-security-group-id"
  type  = "String"
  value = local.parameter_store_values.ecs_security_group_id
  
  tags = local.tags
}

# Store IAM Role ARN
resource "aws_ssm_parameter" "ecs_task_execution_role_arn" {
  name  = "/${var.environment}/${var.module_name}/ecs-task-execution-role-arn"
  type  = "String"
  value = local.parameter_store_values.ecs_task_execution_role_arn
  
  tags = local.tags
}

# Store ECR details
resource "aws_ssm_parameter" "ecr_repository_url" {
  name  = "/${var.environment}/${var.module_name}/ecr-repository-url"
  type  = "String"
  value = local.parameter_store_values.ecr_repository_url
  
  tags = local.tags
}

resource "aws_ssm_parameter" "ecr_repository_arn" {
  name  = "/${var.environment}/${var.module_name}/ecr-repository-arn"
  type  = "String"
  value = local.parameter_store_values.ecr_repository_arn
  
  tags = local.tags
}

resource "aws_ssm_parameter" "ecr_repository_name" {
  name  = "/${var.environment}/${var.module_name}/ecr-repository-name"
  type  = "String"
  value = local.parameter_store_values.ecr_repository_name
  
  tags = local.tags
}

# Store VPC Link ID
resource "aws_ssm_parameter" "vpc_link_id" {
  name  = "/${var.environment}/${var.module_name}/vpc-link-id"
  type  = "String"
  value = local.parameter_store_values.vpc_link_id
  
  tags = local.tags
}



# ========================================
# COMMENTED OUT - FOR FUTURE PIPELINE 2
# ========================================

# # Compute module: ECS Cluster
# module "compute" {
#   source             = "./modules/compute"
#   environment        = var.environment
#   vpc_id             = data.aws_vpc.existing.id
#   private_subnet_ids = module.networking.private_subnet_ids
#   tags               = local.tags
# }

# # ECS Service module: Task definition and ECS service
# module "ecs_service" {
#   source             = "./modules/ecs-service"
#   environment        = var.environment
#   cluster_name       = module.compute.ecs_cluster_name
#   service_name       = "${var.environment}-alr-ecs-service"
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
#   vpc_id           = data.aws_vpc.existing.id
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