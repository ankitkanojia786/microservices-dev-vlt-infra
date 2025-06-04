environment = "usstg-usw2"

# VPC Configuration
vpc_cidr             = "10.2.0.0/16"
public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs = ["10.2.3.0/24", "10.2.4.0/24"]

# ECS Configuration
container_port  = 80
container_cpu   = 512
container_memory = 1024
desired_count   = 2




# Tags
tags = {
  "ohi:project"     = "vlt",
  "ohi:application" = "vlt-subscription",
  "ohi:module"      = "vlt-subscription-be",
  "ohi:environment" = "usstg-usw2",
  "Environment"     = "Staging"
}

# GitHub Integration (dummy values for local testing)
terraform_codestar_connection_arn = "arn:aws:codestar-connections:us-west-2:123456789012:connection/example"
terraform_repository_id = "ankitkanojia786/microservices-dev-vlt-infra"
terraform_branch_name = "main"