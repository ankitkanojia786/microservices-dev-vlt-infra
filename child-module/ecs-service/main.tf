resource "aws_ecs_task_definition" "this" {
  family                   = "${var.environment}-alr-ecs-task-definitions"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = var.task_exec_role_arn
  
  container_definitions = jsonencode([
    {
      name      = "alr-subscription-service"
      image     = var.ecr_image
      essential = true
      
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.environment}-alr-subscription"
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
  
  tags = {
    "ohi:project"     = "alr"
    "ohi:application" = "alr-mobile"
    "ohi:module"      = "alr-subscription"
    "ohi:environment" = var.environment
    "ohi:stack-name"  = "${var.environment}-alr-subscription-microservice-tf-init-pipeline"
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.environment}-alr-subscription"
  retention_in_days = 30
  
  tags = {
    "ohi:project"     = "alr"
    "ohi:application" = "alr-mobile"
    "ohi:module"      = "alr-subscription"
    "ohi:environment" = var.environment
    "ohi:stack-name"  = "${var.environment}-alr-subscription-microservice-tf-init-pipeline"
  }
}

resource "aws_ecs_service" "this" {
  name            = "${var.environment}-alr-ecs-service"
  cluster         = var.cluster_name
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "alr-subscription-service"
    container_port   = var.container_port
  }
  
  tags = {
    "ohi:project"     = "alr"
    "ohi:application" = "alr-mobile"
    "ohi:module"      = "alr-subscription"
    "ohi:environment" = var.environment
    "ohi:stack-name"  = "${var.environment}-alr-subscription-microservice-tf-init-pipeline"
  }
}