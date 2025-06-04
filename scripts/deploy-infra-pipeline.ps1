# PowerShell script to deploy the Terraform infrastructure pipeline

# Parameters
param(
    [string]$Environment = "usdev-usw2",
    [string]$ProjectName = "vlt-subscription",
    [string]$TerraformRepositoryOwner = "ankitkanojia786",
    [string]$TerraformRepositoryName = "microservices-dev-vlt-infra",
    [string]$TerraformBranchName = "main"
)

# Set AWS region
$Region = "us-west-2"

# Create S3 bucket for Terraform state if it doesn't exist
$StateBucketName = "$Environment-$ProjectName-terraform-state"
Write-Host "Creating S3 bucket for Terraform state: $StateBucketName"
aws s3api create-bucket --bucket $StateBucketName --region $Region --create-bucket-configuration LocationConstraint=$Region

# Deploy CloudFormation stack
$StackName = "$Environment-$ProjectName-terraform-pipeline"
Write-Host "Deploying CloudFormation stack: $StackName"

aws cloudformation deploy `
    --stack-name $StackName `
    --template-file ../cloudformation/pipeline.yaml `
    --parameter-overrides `
        ProjectName=$ProjectName `
        Environment=$Environment `
        TerraformRepositoryName=$TerraformRepositoryName `
        TerraformRepositoryOwner=$TerraformRepositoryOwner `
        TerraformBranchName=$TerraformBranchName `
    --capabilities CAPABILITY_NAMED_IAM `
    --region $Region

# Get outputs from CloudFormation stack
Write-Host "Getting CloudFormation stack outputs"
$Outputs = aws cloudformation describe-stacks --stack-name $StackName --region $Region | ConvertFrom-Json

# Display important information
Write-Host "`nPipeline Deployment Complete!`n"
Write-Host "Important Information:"
Write-Host "======================"

foreach ($Output in $Outputs.Stacks[0].Outputs) {
    Write-Host "$($Output.OutputKey): $($Output.OutputValue)"
}

Write-Host "`nNOTE: You need to complete the GitHub connection in the AWS Console:"
Write-Host "1. Go to Developer Tools > Settings > Connections"
Write-Host "2. Find the connection named '$Environment-$ProjectName-github-connection'"
Write-Host "3. Click 'Update pending connection' and follow the steps to authorize AWS to access your GitHub repository"
Write-Host "`nAfter completing the connection, your pipeline will be ready to use."