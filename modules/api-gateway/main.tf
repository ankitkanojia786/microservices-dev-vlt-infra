resource "aws_apigatewayv2_api" "this" {
  name          = "${var.environment}-vlt-subscription-apigateway"
  protocol_type = "HTTP"
  
  tags = var.tags
}

resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "${var.environment}-vlt-subscription-vpc-link"
  security_group_ids = []
  subnet_ids         = var.subnet_ids
  
  tags = var.tags
}

resource "aws_apigatewayv2_integration" "this" {
  api_id           = aws_apigatewayv2_api.this.id
  integration_type = "HTTP_PROXY"
  
  integration_uri    = var.alb_listener_arn
  integration_method = "ANY"
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.this.id
}

resource "aws_apigatewayv2_route" "this" {
  api_id    = aws_apigatewayv2_api.this.id
  route_key = "ANY /{proxy+}"
  
  target = "integrations/${aws_apigatewayv2_integration.this.id}"
}

resource "aws_apigatewayv2_stage" "this" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true
  
  tags = var.tags
}