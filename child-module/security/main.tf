# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${split("-", var.environment)[0]}-${split("-", var.environment)[1]}-alr-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.tags, {
    Name = "${split("-", var.environment)[0]}-${split("-", var.environment)[1]}-alr-alb-sg"
  })
}

# ECS Security Group
resource "aws_security_group" "ecs" {
  name        = "${split("-", var.environment)[0]}-${split("-", var.environment)[1]}-alr-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.tags, {
    Name = "${split("-", var.environment)[0]}-${split("-", var.environment)[1]}-alr-ecs-sg"
  })
}

