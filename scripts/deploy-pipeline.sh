#!/bin/bash

# Deploy ALR Infrastructure Pipeline via CloudFormation
# Usage: ./deploy-pipeline.sh <environment>

ENVIRONMENT=$1

if [ -z "$ENVIRONMENT" ]; then
    echo "Usage: $0 <environment>"
    echo "Example: $0 usdev-usw2"
    exit 1
fi

echo "=== Deploying ALR Infrastructure Pipeline ==="
echo "Environment: $ENVIRONMENT"

# Deploy CloudFormation stack
aws cloudformation deploy \
    --template-file cloudformation/alr-infra-pipeline.yaml \
    --stack-name "$ENVIRONMENT-alr-infra-pipeline-stack" \
    --parameter-overrides \
        Environment="$ENVIRONMENT" \
    --capabilities CAPABILITY_NAMED_IAM \
    --region us-west-2

if [ $? -eq 0 ]; then
    echo "=== Pipeline deployed successfully ==="
    echo "Pipeline Name: $ENVIRONMENT-alr-infra-pipeline"
    echo "Stack Name: $ENVIRONMENT-alr-infra-pipeline-stack"
    echo ""
    echo "Next steps:"
    echo "1. Go to CodePipeline console to view the pipeline"
    echo "2. Pipeline will auto-trigger on GitHub commits to main branch"
    echo "3. Manual approval required in pipeline console after plan stage"
else
    echo "=== Pipeline deployment failed ==="
    exit 1
fi