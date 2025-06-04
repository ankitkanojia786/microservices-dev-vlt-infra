environment = "usprod-usw2"

# VPC Configuration
vpc_cidr             = "10.3.0.0/16"
public_subnet_cidrs  = ["10.3.1.0/24", "10.3.2.0/24"]
private_subnet_cidrs = ["10.3.3.0/24", "10.3.4.0/24"]

# ECS Configuration
container_port  = 80
container_cpu   = 1024
container_memory = 2048
desired_count   = 4

# Tags
tags = {
  "Environment" = "Production"
}