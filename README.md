# ALR Subscription Microservice Infrastructure

This repository contains Terraform infrastructure code for the ALR Subscription Microservice.

## Overview

This infrastructure pipeline creates the foundational AWS resources needed for the ALR subscription microservice deployment.

## Architecture

### Pipeline 1: Infrastructure Pipeline (Current)
Creates the following resources:
- **VPC & Networking**: Subnets, Route Tables, NAT Gateway, Internet Gateway
- **Security**: Security Groups, IAM Roles
- **Load Balancer**: Application Load Balancer (ALB) and Target Group
- **Container Registry**: ECR Repository
- **Parameter Store**: Infrastructure values for Pipeline 2

### Pipeline 2: Application Pipeline (Future)
Will deploy:
- ECS Cluster, Service, and Task Definitions
- API Gateway
- CloudWatch Monitoring

## Resource Naming Convention

All resources follow the pattern: `<country+env>-<aws-region>-alr-subscription-<resource-type>`

Examples:
- ALB: `usdev-usw2-alr-subscription-alb`
- Target Group: `usdev-usw2-alr-subscription-tg`
- ECR: `usdev-usw2-alr-subscription-microservice-ecr`
- VPC: `usdev-usw2-alr-subscription-microservice-vpc`

**Note**: ALB and Target Group names are shortened to comply with AWS 32-character limit.

## Supported Regions

- **US West 2**: usdev-usw2, usqa-usw2, usstg-usw2, usprod-usw2
- **US East 1**: usdev-use1, usqa-use1, usstg-use1, usprod-use1
- **US East 2**: usdev-use2, usqa-use2, usstg-use2, usprod-use2
- **EU West 1**: eudev-euw1, euqa-euw1, eustg-euw1, euprod-euw1

## Deployment

### Prerequisites
1. AWS CLI configured
2. GitHub repository access
3. CloudFormation template deployment

### Steps
1. Delete old CloudFormation stack (if exists): `usdev-usw2-vlt-subscription-infra-pipeline`
2. Deploy new CloudFormation stack: `usdev-usw2-alr-subscription-infra-pipeline-stack`
   - Template: `cloudformation/pipeline.yaml`
   - Environment parameter: `usdev-usw2`
3. Configure GitHub connection in CodePipeline
4. Pipeline will automatically provision infrastructure

### CloudFormation Stack Names
- **Old Stack**: `usdev-usw2-vlt-subscription-infra-pipeline` (to be deleted)
- **New Stack**: `usdev-usw2-alr-subscription-infra-pipeline-stack`

## Parameter Store

Infrastructure values are stored in AWS Parameter Store for Pipeline 2:
- `/${environment}/alr-subscription-microservice/vpc-id`
- `/${environment}/alr-subscription-microservice/private-subnet-ids`
- `/${environment}/alr-subscription-microservice/public-subnet-ids`
- `/${environment}/alr-subscription-microservice/alb-arn`
- `/${environment}/alr-subscription-microservice/alb-dns-name`
- `/${environment}/alr-subscription-microservice/target-group-arn`
- `/${environment}/alr-subscription-microservice/ecs-security-group-id`
- `/${environment}/alr-subscription-microservice/ecs-task-execution-role-arn`
- `/${environment}/alr-subscription-microservice/ecr-repository-url`
- `/${environment}/alr-subscription-microservice/ecr-repository-name`

## Tags

All resources are tagged with:
- `ohi:project`: alr
- `ohi:application`: alr-mobile
- `ohi:module`: alr-subscription
- `ohi:environment`: Environment identifier (e.g., usdev-usw2)
- `ohi:stack-name`: `${environment}-alr-subscription-microservice-tf-init-pipeline`

## Files Structure

```
├── cloudformation/          # CloudFormation templates
│   └── pipeline.yaml       # Infrastructure pipeline template
├── modules/                 # Terraform modules
│   ├── networking/         # VPC, subnets, routing
│   ├── security/           # Security groups, IAM
│   ├── alb/               # Application Load Balancer
│   ├── ecr/               # Container registry
│   ├── compute/           # ECS Cluster (commented out)
│   ├── ecs-service/       # ECS Service (commented out)
│   ├── api-gateway/       # API Gateway (commented out)
│   └── monitoring/        # CloudWatch (commented out)
├── environments/           # Environment-specific variables
├── scripts/               # Deployment scripts
├── main.tf                # Main Terraform configuration
├── variables.tf           # Variable definitions
├── outputs.tf             # Output definitions
├── provider.tf            # AWS provider configuration
├── backend.tf             # Terraform backend configuration
└── buildspec-terraform.yml # CodeBuild specification
```

## Recent Updates

- **Updated from VLT to ALR naming conventions**
- **Added multi-region support**
- **Implemented Parameter Store integration for Pipeline 2**
- **Optimized ALB/Target Group naming for AWS limits**
- **Added comprehensive variable support**

## Support

For questions or issues, contact the infrastructure team.

---
**Last Updated**: Infrastructure ready for ALR deployment with proper naming conventions and multi-region support.