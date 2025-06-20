# ALR Infrastructure Pipeline - Multi-Environment Deployment Guide

## Overview
This guide covers deploying the ALR infrastructure across multiple environments (dev → qa → stg → beta → prod) and regions (US, EU, and future regions).

## Environment Progression
```
dev → qa → stg → prod → beta
```

## Supported Environments

### US Environments
- `usdev-usw2` - US Development (us-west-2)
- `usqa-usw2` - US QA (us-west-2)
- `usstg-usw2` - US Staging (us-west-2)
- `usprod-usw2` - US Production (us-west-2)
- `usbeta-usw2` - US Beta (us-west-2)

### EU Environments
- `eudev-euw1` - EU Development (eu-west-1)
- `euqa-euw1` - EU QA (eu-west-1)
- `eustg-euw1` - EU Staging (eu-west-1)
- `euprod-euw1` - EU Production (eu-west-1)
- `eubeta-euw1` - EU Beta (eu-west-1)

## Deployment Methods

### Method 1: PowerShell Script (Recommended)
```powershell
# Plan infrastructure changes
.\scripts\deploy-environment.ps1 -Environment "usdev-usw2" -Action "plan"

# Apply infrastructure changes
.\scripts\deploy-environment.ps1 -Environment "usdev-usw2" -Action "apply"

# Destroy infrastructure (if needed)
.\scripts\deploy-environment.ps1 -Environment "usdev-usw2" -Action "destroy"
```

### Method 2: Manual Terraform Commands
```bash
# Initialize with environment-specific backend
terraform init -backend-config="backend-configs/usdev-usw2.hcl" -reconfigure

# Plan with environment-specific variables
terraform plan -var-file="environments/usdev-usw2.tfvars" -out="usdev-usw2.tfplan"

# Apply the plan
terraform apply "usdev-usw2.tfplan"
```

## Environment-Specific Configurations

### Tags Applied to All Resources
```hcl
ohi:project     = "alr"
ohi:application = "alr-mobile"
ohi:module      = "alr-be"
ohi:environment = "<environment>"
ohi:stack-name  = "<environment>-alr-infra-pipeline-stack"
```

### Resource Naming Convention
- **ECR Repository**: `<country+env>-<aws-region>-alr-ecr`
  - Example: `usdev-usw2-alr-ecr`, `euqa-euw1-alr-ecr`
- **ALB**: `<country+env>-<aws-region>-alr-alb`
  - Example: `usdev-usw2-alr-alb`, `euqa-euw1-alr-alb`

### Parameter Store Paths
All parameters stored under: `/<environment>/alr-be/<parameter-name>`
- Example: `/usdev-usw2/alr-be/vpc-id`

## Deployment Workflow

### 1. Development Environment (First Deployment)
```powershell
# US Development
.\scripts\deploy-environment.ps1 -Environment "usdev-usw2" -Action "plan"
.\scripts\deploy-environment.ps1 -Environment "usdev-usw2" -Action "apply"

# EU Development (if needed)
.\scripts\deploy-environment.ps1 -Environment "eudev-euw1" -Action "plan"
.\scripts\deploy-environment.ps1 -Environment "eudev-euw1" -Action "apply"
```

### 2. QA Environment
```powershell
# After dev validation
.\scripts\deploy-environment.ps1 -Environment "usqa-usw2" -Action "plan"
.\scripts\deploy-environment.ps1 -Environment "usqa-usw2" -Action "apply"
```

### 3. Staging Environment
```powershell
# After QA validation
.\scripts\deploy-environment.ps1 -Environment "usstg-usw2" -Action "plan"
.\scripts\deploy-environment.ps1 -Environment "usstg-usw2" -Action "apply"
```

### 4. Production Environment
```powershell
# After staging validation
.\scripts\deploy-environment.ps1 -Environment "usprod-usw2" -Action "plan"
.\scripts\deploy-environment.ps1 -Environment "usprod-usw2" -Action "apply"
```

### 5. Beta Environment
```powershell
# After production validation
.\scripts\deploy-environment.ps1 -Environment "usbeta-usw2" -Action "plan"
.\scripts\deploy-environment.ps1 -Environment "usbeta-usw2" -Action "apply"
```

## Adding New Regions

### Step 1: Update Region Mapping
Add new region to `variables.tf`:
```hcl
variable "region_mapping" {
  default = {
    # Existing regions...
    "aps1"  = "ap-south-1"      # Asia Pacific
    "apse1" = "ap-southeast-1"   # Singapore
    "cac1"  = "ca-central-1"     # Canada
  }
}
```

### Step 2: Create Backend Configuration
Create `backend-configs/<new-env>.hcl`:
```hcl
bucket         = "<region-specific-bucket>"
key            = "alr/<environment>/infra-pipeline/terraform.tfstate"
region         = "<aws-region>"
encrypt        = true
dynamodb_table = "terraform-state-lock"
```

### Step 3: Create Environment Variables
Create `environments/<new-env>.tfvars` with appropriate values.

### Step 4: Update Deployment Script
Add new environment to the ValidateSet in `deploy-environment.ps1`.

## Infrastructure Components Created

### Core Infrastructure
- ✅ Subnets (public/private in existing VPC)
- ✅ Route Tables and NAT Gateway
- ✅ Security Groups (ALB and ECS)
- ✅ IAM Roles (ECS task execution)

### Application Resources
- ✅ ECR Repository (container images)
- ✅ Application Load Balancer
- ✅ Parameter Store values (for app pipeline)

## Troubleshooting

### Common Issues
1. **Backend bucket doesn't exist**: Ensure S3 bucket exists in target region
2. **DynamoDB table missing**: Create terraform-state-lock table
3. **VPC not found**: Ensure VPC exists with correct naming convention
4. **Permission denied**: Check AWS credentials and IAM permissions

### Validation Commands
```bash
# Check current environment
terraform workspace show

# Validate configuration
terraform validate

# Check state
terraform state list

# Show current configuration
terraform show
```

## Best Practices

### 1. Always Plan First
Never apply directly without reviewing the plan output.

### 2. Environment Isolation
Each environment has its own:
- Backend state file
- Variable file
- Resource naming

### 3. Progressive Deployment
Follow the environment progression: dev → qa → stg → prod → beta

### 4. Backup State Files
Ensure S3 versioning is enabled for state files.

### 5. Monitor Resources
Check AWS CloudWatch and billing after deployments.

## Support
For deployment issues:
1. Check CloudWatch logs
2. Review Terraform state
3. Verify AWS permissions
4. Contact DevOps team