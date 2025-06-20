# ALR Subscription Microservice - Infrastructure Pipeline

## Overview
This repository contains the Terraform Infrastructure Pipeline for the ALR (Allura) Subscription microservice, implementing a two-pipeline deployment workflow with clear separation between infrastructure provisioning and application deployment.

## Pipeline Details

### Pipeline Name
- **US Environments**: `usdev-usw2-alr-infra`, `usqa-usw2-alr-infra`, `usprod-usw2-alr-infra`
- **EU Environments**: `eudev-euw1-alr-infra`, `euqa-euw1-alr-infra`, `euprod-euw1-alr-infra`

### Purpose
Handles provisioning of all infrastructure components needed for the ALR Subscription microservice runtime.

## Pipeline Phases

### 1. Source
- Pulls Terraform code from GitHub repository
- Uses CodeStar connection for secure access

### 2. Terraform Plan
- Previews infrastructure changes
- Validates Terraform configuration
- Generates execution plan

### 3. Manual Approval
- Requires manual confirmation before applying changes
- Allows review of planned infrastructure modifications

### 4. Terraform Apply
- Provisions infrastructure components
- Creates all required AWS resources

## Infrastructure Components Provisioned

### Core Infrastructure
- **Subnets**: Public and private subnets in existing VPC
- **Route Tables**: Routing configuration for subnets
- **Security Groups**: Network security rules for ALB and ECS
- **NAT Gateway**: Outbound internet access for private subnets
- **IAM Roles**: ECS task execution roles with required permissions

### Application-Specific Resources
- **ECR Repository**: `<country+env>-<aws-region>-alr-ecr`
  - Example: `usdev-usw2-alr-ecr`, `eudev-euw1-alr-ecr`
- **Application Load Balancer**: `<country+env>-<aws-region>-alr-alb`
  - Example: `usdev-usw2-alr-alb`, `eudev-euw1-alr-alb`

### Integration Components
- **Parameter Store**: Values for Application Pipeline consumption
  - VPC and subnet information
  - Security group IDs
  - ALB and ECR details
  - IAM role ARNs

## Execution Model

### Trigger
- **Manual execution** during initial infrastructure setup
- **On-demand** when infrastructure updates are required

### Re-run Scenarios
- New environment setup
- Infrastructure component updates
- Security group modifications
- IAM role changes

## Environment Support

### US Regions
- `usdev-usw2` (US Development - US West 2)
- `usqa-usw2` (US QA - US West 2)
- `usprod-usw2` (US Production - US West 2)

### EU Regions
- `eudev-euw1` (EU Development - EU West 1)
- `euqa-euw1` (EU QA - EU West 1)
- `euprod-euw1` (EU Production - EU West 1)

## Prerequisites

### Existing Infrastructure
- **VPC**: Must exist with naming convention `<environment>-vpc`
- **S3 Backend**: Terraform state bucket configured
- **DynamoDB**: State locking table available

### Permissions
- CodeBuild service role with Terraform execution permissions
- Access to target AWS account and region
- Parameter Store write permissions

## Configuration Files

### Key Files
- `main.tf`: Main Terraform configuration
- `variables.tf`: Variable definitions
- `backend.tf`: S3 backend configuration
- `buildspec-terraform.yml`: CodeBuild specification
- `terraform.tfvars`: Environment-specific values

### Module Structure
```
modules/
├── networking/     # Subnets, route tables, NAT gateway
├── security/       # Security groups, IAM roles
├── alb/           # Application Load Balancer
└── ecr/           # ECR repository
```

## Naming Conventions

### Resources
- ECR Repository: `<country+env>-<aws-region>-alr-ecr`
- ALB: `<country+env>-<aws-region>-alr-alb`
- Parameter Store: `/<environment>/alr-be/<resource-name>`

### Tags
All resources tagged with:
- `ohi:project`: `alr`
- `ohi:application`: `alr-subscription`
- `ohi:module`: `alr-subscription-be`
- `ohi:environment`: `<environment>`
- `ohi:stack-name`: `<environment>-alr-infra-pipeline-stack`

## Integration with Application Pipeline

This infrastructure pipeline prepares resources for the Application Pipeline (Pipeline 2) by:

1. **Creating infrastructure components** required for ECS service deployment
2. **Storing configuration values** in Parameter Store for application pipeline consumption
3. **Establishing networking** and security foundations
4. **Providing ECR repository** for container image storage

## Monitoring and Maintenance

### State Management
- Terraform state stored in S3 with encryption
- State locking via DynamoDB
- Environment-specific state files

### Updates
- Infrastructure changes require pipeline re-execution
- Manual approval ensures controlled deployments
- Rollback capability through Terraform state management

## Support

For issues or questions regarding the infrastructure pipeline:
1. Check CloudWatch logs for build failures
2. Review Terraform plan output for resource conflicts
3. Verify AWS permissions and resource limits
4. Contact the Voltron Cloud team for pipeline-specific issues