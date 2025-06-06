environment = "usdev-usw2"

# VPC Configuration
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

# ECS Configuration
container_port  = 80
container_cpu   = 256
container_memory = 512
desired_count   = 1

# Tags
tags = {
  "ohi:project"     = "vlt",
  "ohi:application" = "vlt-subscription",
  "ohi:module"      = "vlt-subscription-be",
  "ohi:environment" = "usdev-usw2"
}

# GitHub Integration (dummy values for local testing)
terraform_codestar_connection_arn = "arn:aws:codeconnections:us-west-2:913524921936:connection/e969f690-6a17-4e87-ba3c-6ee96cdf88ff"
terraform_repository_id = "ankitkanojia786/microservices-dev-vlt-infra"
terraform_branch_name = "main"
