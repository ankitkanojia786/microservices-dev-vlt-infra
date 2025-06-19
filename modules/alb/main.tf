resource "aws_lb" "this" {
  name               = "${var.environment}-alr-subscription-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids
  
  enable_deletion_protection = false
  
  tags = {
    "ohi:project"     = "alr"
    "ohi:application" = "alr-mobile"
    "ohi:module"      = "alr-subscription"
    "ohi:environment" = var.environment
    "ohi:stack-name"  = "${var.environment}-alr-subscription-microservice-tf-init-pipeline"
  }
}

resource "aws_lb_target_group" "this" {
  name        = "${var.environment}-alr-subscription-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  
  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    matcher             = "200-299"
  }
  
  tags = {
    "ohi:project"     = "alr"
    "ohi:application" = "alr-mobile"
    "ohi:module"      = "alr-subscription"
    "ohi:environment" = var.environment
    "ohi:stack-name"  = "${var.environment}-alr-subscription-microservice-tf-init-pipeline"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"
  
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}