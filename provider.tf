provider "aws" {
  region = var.region_mapping[split("-", var.environment)[1]]
}

# Required for ECS task execution role policy
data "aws_partition" "current" {}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}