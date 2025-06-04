param(
    [Parameter(Mandatory=$true)]
    [string]$EnvFile
)

# Extract environment from tfvars file
$envContent = Get-Content $EnvFile -Raw
if ($envContent -match 'environment\s*=\s*"([^"]+)"') {
    $environment = $matches[1]
    Write-Host "Detected environment: $environment"
} else {
    Write-Error "Could not detect environment in $EnvFile"
    exit 1
}

# Create S3 bucket for environment state if it doesn't exist
$StateBucketName = "$environment-vlt-subscription-terraform-state"
Write-Host "Checking/creating S3 bucket for Terraform state: $StateBucketName"
try {
    aws s3api head-bucket --bucket $StateBucketName 2>&1 | Out-Null
    Write-Host "Bucket already exists"
} catch {
    Write-Host "Creating bucket..."
    aws s3api create-bucket --bucket $StateBucketName --region us-west-2 --create-bucket-configuration LocationConstraint=us-west-2
}

# Create backend.tf file for the environment
Write-Host "Creating backend.tf for $environment"
@"
terraform {
  backend "s3" {
    bucket         = "$StateBucketName"
    key            = "terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
"@ | Out-File -FilePath .\backend.tf -Force

# Copy tfvars file to working directory
Write-Host "Copying $EnvFile to terraform.tfvars"
Copy-Item $EnvFile .\terraform.tfvars -Force

# Initialize Terraform with the environment backend
Write-Host "Initializing Terraform with $environment backend"
terraform init -reconfigure

Write-Host "`nEnvironment setup complete for $environment"
Write-Host "Run 'terraform plan' to see the changes for this environment"