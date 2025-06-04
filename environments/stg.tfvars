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
  "Environment" = "Staging"
}