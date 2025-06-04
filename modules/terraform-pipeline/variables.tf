variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "terraform_codestar_connection_arn" {
  description = "ARN of the CodeStar connection for Terraform repository"
  type        = string
}

variable "terraform_repository_id" {
  description = "GitHub/BitBucket repository ID for Terraform code"
  type        = string
}

variable "terraform_branch_name" {
  description = "Branch to use for Terraform code"
  type        = string
  default     = "main"
}

variable "terraform_buildspec_path" {
  description = "Path to the buildspec file for Terraform"
  type        = string
  default     = "buildspec-terraform.yml"
}
