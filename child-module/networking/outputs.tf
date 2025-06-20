output "vpc_id" {
  value = var.vpc_id
}

# Map format for parameter store loops
output "public_subnet_ids" {
  value = { for k, v in aws_subnet.public : k => v.id }
}

output "private_subnet_ids" {
  value = { for k, v in aws_subnet.private : k => v.id }
}

# List format for ALB and VPC Link
output "public_subnet_ids_list" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids_list" {
  value = aws_subnet.private[*].id
}