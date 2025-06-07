variable "environment" {
  description = "Environment name (e.g., usdev-usw2, usqa-usw2)"
  type        = string
}

variable "country_environment" {
  description = "Country environment identifier (e.g., usdev)"
  type        = string
}

variable "deployment_region" {
  description = "Deployment region identifier (e.g., usw2)"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "enable_docker_push" {
  description = "Whether to enable Docker image building and pushing"
  type        = bool
  default     = false
}

