param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "qa", "stg", "beta", "prod")]
    [string]$Environment
)

# Determine which bucket to use
if ($Environment -eq "prod") {
    $StateBucketName = "usprod-usw2-terraform-microservices-statefile-bucket"
} else {
    $StateBucketName = "usnp-usw2-terraform-microservices-statefile-bucket"
}

# Create S3 bucket if it doesn't exist
Write-Host "Checking/creating S3 bucket for Terraform state: $StateBucketName"
try {
    aws s3api head-bucket --bucket $StateBucketName 2>&1 | Out-Null
    Write-Host "Bucket already exists"
} catch {
    Write-Host "Creating bucket..."
    aws s3api create-bucket --bucket $StateBucketName --region us-west-2 --create-bucket-configuration LocationConstraint=us-west-2
}

# Create backend.tf file for the environment
Write-Host "Creating backend.tf for $Environment"
@"
terraform {
  backend "s3" {
    bucket         = "$StateBucketName"
    key            = "environments/$Environment/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
"@ | Out-File -FilePath .\backend.tf -Force

# Copy tfvars file to working directory
$TfvarsPath = "..\terraform\environments\$Environment.tfvars"
if (Test-Path $TfvarsPath) {
    Write-Host "Copying $TfvarsPath to terraform.tfvars"
    Copy-Item $TfvarsPath .\terraform.tfvars -Force
} else {
    Write-Error "Environment file not found: $TfvarsPath"
    exit 1
}

# Initialize Terraform with the environment backend
Write-Host "Initializing Terraform with $Environment backend"
terraform init -reconfigure

Write-Host "`nEnvironment setup complete for $Environment"
Write-Host "Run 'terraform plan' to see the changes for this environment"