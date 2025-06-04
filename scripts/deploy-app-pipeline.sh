#!/bin/bash

# Script to deploy the application pipeline using CloudFormation

# Parameters
ENVIRONMENT=$1
REGION="us-west-2"
STACK_NAME="${ENVIRONMENT}-vlt-subscription-app-pipeline"

# Validate environment parameter
if [ -z "$ENVIRONMENT" ]; then
  echo "Usage: $0 <environment>"
  echo "Environment options: usdev-usw2, usqa-usw2, usstg-usw2, usprod-usw2, usbeta-usw2"
  exit 1
fi

# Get the ECR repository name, ECS cluster name, ECS service name, and task definition name from Terraform outputs
ECR_REPO_NAME=$(aws cloudformation describe-stacks --stack-name ${ENVIRONMENT}-vlt-subscription-infra --query "Stacks[0].Outputs[?OutputKey=='EcrRepositoryName'].OutputValue" --output text --region $REGION)
ECS_CLUSTER_NAME=$(aws cloudformation describe-stacks --stack-name ${ENVIRONMENT}-vlt-subscription-infra --query "Stacks[0].Outputs[?OutputKey=='EcsClusterName'].OutputValue" --output text --region $REGION)
ECS_SERVICE_NAME=$(aws cloudformation describe-stacks --stack-name ${ENVIRONMENT}-vlt-subscription-infra --query "Stacks[0].Outputs[?OutputKey=='EcsServiceName'].OutputValue" --output text --region $REGION)
TASK_DEFINITION_NAME=$(aws cloudformation describe-stacks --stack-name ${ENVIRONMENT}-vlt-subscription-infra --query "Stacks[0].Outputs[?OutputKey=='TaskDefinitionName'].OutputValue" --output text --region $REGION)

# Deploy the CloudFormation stack
aws cloudformation deploy \
  --template-file cloudformation/app-pipeline.yaml \
  --stack-name $STACK_NAME \
  --parameter-overrides \
    Environment=$ENVIRONMENT \
    EcrRepositoryName=$ECR_REPO_NAME \
    EcsClusterName=$ECS_CLUSTER_NAME \
    EcsServiceName=$ECS_SERVICE_NAME \
    TaskDefinitionName=$TASK_DEFINITION_NAME \
  --capabilities CAPABILITY_NAMED_IAM \
  --region $REGION

echo "Application pipeline deployed successfully!"