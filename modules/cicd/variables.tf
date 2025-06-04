variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "ecr_repository_url" {
  description = "URL of the ECR repository"
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "codestar_connection_arn" {
  description = "ARN of the CodeStar connection to GitHub/BitBucket"
  type        = string
}

variable "repository_id" {
  description = "GitHub/BitBucket repository ID (e.g., 'username/repo')"
  type        = string
}

variable "branch_name" {
  description = "Branch to use for the source code"
  type        = string
  default     = "main"
}

variable "buildspec_path" {
  description = "Path to the buildspec file"
  type        = string
  default     = "buildspec.yml"
}
