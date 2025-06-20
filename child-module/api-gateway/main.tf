resource "aws_apigatewayv2_api" "this" {
  name          = "${var.environment}-vlt-subscription-microservice-apigateway"
  protocol_type = "HTTP"
  
  tags = {
    "ohi:project"     = "vlt"
    "ohi:application" = "vlt-mobile"
    "ohi:module"      = "vlt-subscription"
    "ohi:environment" = var.environment
  }
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
  
  tags = {
    "ohi:project"     = "vlt"
    "ohi:application" = "vlt-mobile"
    "ohi:module"      = "vlt-subscription"
    "ohi:environment" = var.environment
  }
}

resource "aws_apigatewayv2_integration" "this" {
  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "HTTP_PROXY"
  integration_uri    = var.alb_listener_arn
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.this.id
}

resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /{proxy+}"
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "${var.environment}-vlt-subscription-microservice-vpclink"
  security_group_ids = []
  subnet_ids         = var.subnet_ids
  
  tags = {
    "ohi:project"     = "vlt"
    "ohi:application" = "vlt-mobile"
    "ohi:module"      = "vlt-subscription"
    "ohi:environment" = var.environment
  }
}