environment = "usqa-usw2"

# VPC Configuration
vpc_cidr             = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]

# ECS Configuration
container_port  = 80
container_cpu   = 256
container_memory = 512
desired_count   = 2

# Tags
tags = {
  "Environment" = "QA"
}