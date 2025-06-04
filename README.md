# Subscription Microservice Infrastructure

This repository contains the infrastructure code for the subscription microservice.

## Infrastructure Components

- VPC with public and private subnets
- ECS Cluster (`usdev-usw2-vlt-subscription-ecs-cluster`)
- ECS Service (`usdev-usw2-vlt-subscription-ecs-service`)
- ECR Repository (`usdev-usw2-vlt-subscription-ecr`)
- Application Load Balancer (`usdev-usw2-vlt-subscription-alb`)
- API Gateway (`usdev-usw2-vlt-subscription-apigateway`)
- Security Groups and IAM Roles

## Infrastructure Pipeline

The infrastructure is deployed using a CloudFormation-managed Terraform pipeline:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│                      Infrastructure Pipeline (CloudFormation)           │
│                                                                         │
└───────────────────────────────────┬─────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│                      Terraform Infrastructure Pipeline                  │
│                                                                         │
│  ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────────────┐    │
│  │         │     │         │     │         │     │                 │    │
│  │ Source  ├────►│  Plan   ├────►│ Approve ├────►│     Apply      │    │
│  │         │     │         │     │         │     │                 │    │
│  └─────────┘     └─────────┘     └─────────┘     └────────┬────────┘    │
│                                                           │             │
└───────────────────────────────────────────────────────────┼─────────────┘
                                                            │
                                                            ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                                                                         │
│                        AWS Infrastructure                               │
│                                                                         │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐        │
│  │         │  │         │  │         │  │         │  │         │        │
│  │   VPC   │  │   ECS   │  │   ECR   │  │   ALB   │  │  API GW │        │
│  │         │  │         │  │         │  │         │  │         │        │
│  └─────────┘  └─────────┘  └─────────┘  └─────────┘  └─────────┘        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## Environment Support

The infrastructure supports multiple environments:

- Development (`usdev-usw2`)
- QA (`usqa-usw2`)
- Staging (`usstg-usw2`)
- Production (`usprod-usw2`)
- Beta (`usbeta-usw2`)

## Deployment Instructions

To deploy the infrastructure pipeline:

```bash
aws cloudformation deploy \
  --template-file cloudformation/pipeline.yaml \
  --stack-name usdev-usw2-vlt-subscription-infra-pipeline \
  --parameter-overrides \
    Environment=usdev-usw2 \
  --capabilities CAPABILITY_NAMED_IAM
```

## Required Tags

All resources are tagged with:

- `ohi:project = vlt`
- `ohi:application = vlt-subscription`
- `ohi:module = vlt-subscription-be`
- `ohi:environment = usdev-usw2` (varies by environment)

## Application Deployment

The application code and deployment pipeline are maintained in a separate repository:
[subscription-microservices-app](https://github.com/ankitkanojia786/subscription-microservices-app)