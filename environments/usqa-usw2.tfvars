environment = "usqa-usw2"

# Project Configuration
project_name     = "alr"
application_name = "alr-mobile"
module_name      = "alr-be"

# VPC Configuration
vpc_cidr             = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]

# ECS Configuration
container_port   = 80
container_cpu    = 512
container_memory = 1024
desired_count    = 2

# Infrastructure Pipeline GitHub Integration
terraform_codestar_connection_arn = "arn:aws:codeconnections:us-west-2:913524921936:connection/e969f690-6a17-4e87-ba3c-6ee96cdf88ff"
terraform_repository_id           = "ankitkanojia786/microservices-dev-vlt-infra"
terraform_branch_name             = "main"