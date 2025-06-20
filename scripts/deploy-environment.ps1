# Multi-Environment Deployment Script for ALR Infrastructure Pipeline
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("usdev-usw2", "usqa-usw2", "usstg-usw2", "usprod-usw2", "usbeta-usw2", 
                 "eudev-euw1", "euqa-euw1", "eustg-euw1", "euprod-euw1", "eubeta-euw1")]
    [string]$Environment,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("plan", "apply", "destroy")]
    [string]$Action
)

Write-Host "=== ALR Infrastructure Pipeline Deployment ===" -ForegroundColor Green
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host "Action: $Action" -ForegroundColor Yellow

# Set environment variables
$env:TF_VAR_environment = $Environment

# Initialize Terraform with environment-specific backend
Write-Host "Initializing Terraform with backend configuration..." -ForegroundColor Cyan
terraform init -backend-config="backend-configs/$Environment.hcl" -reconfigure

if ($LASTEXITCODE -ne 0) {
    Write-Error "Terraform init failed"
    exit 1
}

# Validate configuration
Write-Host "Validating Terraform configuration..." -ForegroundColor Cyan
terraform validate

if ($LASTEXITCODE -ne 0) {
    Write-Error "Terraform validation failed"
    exit 1
}

# Execute the specified action
switch ($Action) {
    "plan" {
        Write-Host "Creating Terraform plan..." -ForegroundColor Cyan
        terraform plan -var-file="environments/$Environment.tfvars" -out="$Environment.tfplan"
    }
    "apply" {
        Write-Host "Applying Terraform configuration..." -ForegroundColor Cyan
        if (Test-Path "$Environment.tfplan") {
            terraform apply "$Environment.tfplan"
        } else {
            terraform apply -var-file="environments/$Environment.tfvars" -auto-approve
        }
    }
    "destroy" {
        Write-Host "Destroying infrastructure..." -ForegroundColor Red
        terraform destroy -var-file="environments/$Environment.tfvars" -auto-approve
    }
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "=== Deployment completed successfully ===" -ForegroundColor Green
} else {
    Write-Error "Deployment failed"
    exit 1
}