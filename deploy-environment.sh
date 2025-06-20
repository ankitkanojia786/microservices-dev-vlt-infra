#!/bin/bash

# ALR Infrastructure Pipeline Deployment Script
# Usage: ./deploy-environment.sh <environment> <action>
# Example: ./deploy-environment.sh usdev-usw2 plan

ENVIRONMENT=$1
ACTION=${2:-plan}

if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 <environment> [action]"
    echo "Environments: usdev-usw2, usqa-usw2, usstg-usw2, usprod-usw2, usbeta-usw2"
    echo "Actions: plan, apply, destroy"
    exit 1
fi

echo "=== ALR Infrastructure Pipeline ($ENVIRONMENT-alr-infra) ==="
echo "Environment: $ENVIRONMENT"
echo "Action: $ACTION"

# Initialize Terraform with environment-specific backend
echo "Initializing Terraform..."
terraform init -backend-config="backend-configs/$ENVIRONMENT.hcl" -reconfigure

# Validate configuration
echo "Validating Terraform configuration..."
terraform validate

# Execute action
case "$ACTION" in
    "plan")
        echo "Creating Terraform plan..."
        terraform plan -var-file="environments/$ENVIRONMENT.tfvars" -out="$ENVIRONMENT.tfplan"
        ;;
    "apply")
        echo "Applying Terraform configuration..."
        terraform apply -var-file="environments/$ENVIRONMENT.tfvars" -auto-approve
        ;;
    "destroy")
        echo "Destroying infrastructure..."
        terraform destroy -var-file="environments/$ENVIRONMENT.tfvars" -auto-approve
        ;;
    *)
        echo "Unknown action: $ACTION"
        exit 1
        ;;
esac

echo "=== ALR Infrastructure Pipeline Completed ==="
echo "Pipeline: $ENVIRONMENT-alr-infra"
echo "Action: $ACTION completed successfully"