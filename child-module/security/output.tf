output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "ecs_sg_id" {
  value = aws_security_group.ecs.id
}

# ECS task execution role removed - not needed for infrastructure-only deployment