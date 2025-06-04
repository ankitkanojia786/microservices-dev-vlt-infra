environment = "usbeta-usw2"

# VPC Configuration
vpc_cidr             = "10.4.0.0/16"
public_subnet_cidrs  = ["10.4.1.0/24", "10.4.2.0/24"]
private_subnet_cidrs = ["10.4.3.0/24", "10.4.4.0/24"]

# ECS Configuration
container_port  = 80
container_cpu   = 512
container_memory = 1024
desired_count   = 2

# Tags
tags = {
  "Environment" = "Beta"
}