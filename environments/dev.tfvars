environment = "usdev-usw2"

# VPC Configuration
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]

# ECS Configuration
container_port  = 80
container_cpu   = 256
container_memory = 512
desired_count   = 2

# Tags
tags = {
  "Environment" = "Development"
}