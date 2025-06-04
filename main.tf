# Define local variables
locals {
  # Merge common tags with environment-specific tag
  tags = merge(var.tags, {
    "ohi:environment" = var.environment
  })
}

# Terraform Infrastructure Pipeline module
module "terraform_pipeline" {
  source                         = "./modules/terraform-pipeline"
  project_name                   = "subscription-ms-infra"
  terraform_codestar_connection_arn = var.terraform_codestar_connection_arn
  terraform_repository_id        = var.terraform_repository_id
  terraform_branch_name          = var.terraform_branch_name
  terraform_buildspec_path       = "buildspec-terraform.yml"
}

# Networking module: VPC, Subnets, IGW, NAT
module "networking" {
  source               = "./modules/networking"
  region               = var.region
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

# Compute module: ECS Cluster only
module "compute" {
  source             = "./modules/compute"
  environment        = var.environment
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  tags               = local.tags
}

# ECR module: ECR repositories
module "ecr" {
  source           = "./modules/ecr"
  environment      = var.environment
}

# ECS Service module: Task definition and ECS service
module "ecs_service" {
  source             = "./modules/ecs-service"
  environment        = var.environment
  cluster_name       = module.compute.ecs_cluster_name
  service_name       = "${var.environment}-vlt-subscription-ecs-service"
  task_exec_role_arn = module.security.ecs_task_execution_role_arn
  ecs_sg_id          = module.security.ecs_sg_id
  subnet_ids         = module.networking.private_subnet_ids
  container_port     = var.container_port
  ecr_image          = "${module.ecr.ecr_repo_url}:latest"
  target_group_arn   = module.alb.target_group_arn
  tags               = local.tags
}

# API Gateway module
module "api_gateway" {
  source           = "./modules/api-gateway"
  environment      = var.environment
  vpc_id           = module.networking.vpc_id
  alb_dns_name     = module.alb.alb_dns_name
  alb_listener_arn = module.alb.http_listener_arn
  subnet_ids       = module.networking.private_subnet_ids
  tags             = local.tags
}

# Monitoring module
module "monitoring" {
  source           = "./modules/monitoring"
  environment      = var.environment
  region           = var.region
  ecs_cluster_name = module.compute.ecs_cluster_name
  alert_emails     = var.alert_emails
  tags             = local.tags
}