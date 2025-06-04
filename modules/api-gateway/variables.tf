variable "environment" {
  description = "Environment name (e.g., usdev-usw2, usqa-usw2)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "alb_dns_name" {
  description = "DNS name of the ALB"
  type        = string
}

variable "alb_listener_arn" {
  description = "ARN of the ALB listener"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the VPC Link"
  type        = list(string)
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}