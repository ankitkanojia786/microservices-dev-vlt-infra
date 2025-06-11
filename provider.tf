provider "aws" {
  region = var.aws_regions
}

# Required for ECS task execution role policy
data "aws_partition" "current" {}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}