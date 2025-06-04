# Project Structure

## Infrastructure Repository (microservices-dev-vlt-infra)
```
microservices-dev-vlt-infra/
├── cloudformation/
│   └── pipeline.yaml                # CloudFormation template for the infrastructure pipeline
├── terraform/
│   ├── environments/
│   │   ├── dev.tfvars               # Variables for dev environment
│   │   ├── qa.tfvars                # Variables for qa environment
│   │   ├── stg.tfvars               # Variables for staging environment
│   │   ├── prod.tfvars              # Variables for production environment
│   │   └── beta.tfvars              # Variables for beta environment
│   ├── modules/
│   │   ├── networking/              # VPC, subnets, etc.
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── security/                # Security groups, IAM roles
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── ecr/                     # ECR repositories
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── ecs/                     # ECS cluster, services, task definitions
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   ├── alb/                     # Application Load Balancer
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── api-gateway/             # API Gateway
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   ├── main.tf                      # Main Terraform configuration
│   ├── variables.tf                 # Variable definitions
│   ├── outputs.tf                   # Output definitions
│   └── provider.tf                  # Provider configuration
├── buildspec/
│   └── terraform-buildspec.yml      # BuildSpec for Terraform pipeline
└── README.md                        # Project documentation
```

## Application Repository (subscription-microservices-app)
```
subscription-microservices-app/
├── cloudformation/
│   └── app-pipeline.yaml            # CloudFormation template for application pipeline
├── app.js                           # Application code
├── Dockerfile                       # Docker build instructions
├── package.json                     # Node.js dependencies
├── buildspec.yml                    # BuildSpec for application build/deploy
├── appspec.yml                      # AppSpec for ECS deployment
├── deploy-app-pipeline.sh           # Script to deploy the application pipeline
└── README.md                        # Application documentation
```