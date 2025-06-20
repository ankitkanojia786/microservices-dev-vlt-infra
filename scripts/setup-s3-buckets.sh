#!/bin/bash

# ALR Infrastructure - S3 Buckets Setup Script

echo "=== Setting up S3 buckets for ALR Infrastructure ==="

# Create Non-Production S3 bucket
echo "Creating non-production S3 bucket..."
aws s3 mb s3://alr-nonprod-terraform-state --region us-west-2

# Enable versioning for non-prod bucket
aws s3api put-bucket-versioning \
    --bucket alr-nonprod-terraform-state \
    --versioning-configuration Status=Enabled

# Create Production S3 bucket
echo "Creating production S3 bucket..."
aws s3 mb s3://alr-prod-terraform-state --region us-west-2

# Enable versioning for prod bucket
aws s3api put-bucket-versioning \
    --bucket alr-prod-terraform-state \
    --versioning-configuration Status=Enabled

# Create DynamoDB table for state locking (non-prod)
echo "Creating DynamoDB table for non-prod state locking..."
aws dynamodb create-table \
    --table-name terraform-state-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region us-west-2

# Create DynamoDB table for state locking (prod)
echo "Creating DynamoDB table for prod state locking..."
aws dynamodb create-table \
    --table-name terraform-state-lock-prod \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region us-west-2

echo "=== S3 buckets and DynamoDB tables created successfully ==="
echo "Non-prod bucket: alr-nonprod-terraform-state"
echo "Prod bucket: alr-prod-terraform-state"
echo "DynamoDB tables: terraform-state-lock, terraform-state-lock-prod"