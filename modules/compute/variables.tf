variable "environment" {
  description = "Environment name (e.g., usdev-usw2, usqa-usw2)"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of private subnets"
  type        = list(string)
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
  
}

variable "country_environment" {
  description = "Country environment identifier"
  type        = string
  default     = "usdev"
  
}

variable "deployment_region" {
  description = "Deployment region identifier"
  type        = string
  default     = "usw2"
  
}