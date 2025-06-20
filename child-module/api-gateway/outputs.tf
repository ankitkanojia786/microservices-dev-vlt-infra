output "api_gateway_id" {
  value       = aws_apigatewayv2_api.this.id
  description = "ID of the API Gateway"
}

output "api_gateway_url" {
  value       = aws_apigatewayv2_api.this.api_endpoint
  description = "URL of the API Gateway"
}

output "vpc_link_id" {
  value       = aws_apigatewayv2_vpc_link.this.id
  description = "ID of the VPC Link"
}