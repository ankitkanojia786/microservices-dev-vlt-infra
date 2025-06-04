param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("usdev-usw2", "usqa-usw2", "usstg-usw2", "usprod-usw2", "usbeta-usw2")]
    [string]$Environment
)

# Create S3 bucket for environment state if it doesn't exist
$StateBucketName = "$Environment-vlt-subscription-terraform-state"
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
    key            = "terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
"@ | Out-File -FilePath .\backend.tf -Force

# Create terraform.tfvars file for the environment
Write-Host "Creating terraform.tfvars for $Environment"
$TfvarsPath = "..\terraform\environments\$Environment.tfvars"
if (Test-Path $TfvarsPath) {
    Copy-Item $TfvarsPath .\terraform.tfvars -Force
    Write-Host "Copied environment tfvars file"
} else {
    # Create default tfvars file
    $VpcCidr = switch ($Environment) {
        "usdev-usw2" { "10.0.0.0/16" }
        "usqa-usw2"  { "10.1.0.0/16" }
        "usstg-usw2" { "10.2.0.0/16" }
        "usprod-usw2" { "10.3.0.0/16" }
        "usbeta-usw2" { "10.4.0.0/16" }
    }
    
    $PublicSubnets = switch ($Environment) {
        "usdev-usw2" { '["10.0.1.0/24", "10.0.2.0/24"]' }
        "usqa-usw2"  { '["10.1.1.0/24", "10.1.2.0/24"]' }
        "usstg-usw2" { '["10.2.1.0/24", "10.2.2.0/24"]' }
        "usprod-usw2" { '["10.3.1.0/24", "10.3.2.0/24"]' }
        "usbeta-usw2" { '["10.4.1.0/24", "10.4.2.0/24"]' }
    }
    
    $PrivateSubnets = switch ($Environment) {
        "usdev-usw2" { '["10.0.3.0/24", "10.0.4.0/24"]' }
        "usqa-usw2"  { '["10.1.3.0/24", "10.1.4.0/24"]' }
        "usstg-usw2" { '["10.2.3.0/24", "10.2.4.0/24"]' }
        "usprod-usw2" { '["10.3.3.0/24", "10.3.4.0/24"]' }
        "usbeta-usw2" { '["10.4.3.0/24", "10.4.4.0/24"]' }
    }
    
    @"
region = "us-west-2"
environment = "$Environment"
vpc_cidr = "$VpcCidr"
public_subnet_cidrs = $PublicSubnets
private_subnet_cidrs = $PrivateSubnets
container_port = 80
terraform_codestar_connection_arn = "arn:aws:codestar-connections:us-west-2:123456789012:connection/example"
terraform_repository_id = "ankitkanojia786/microservices-dev-vlt-infra"
terraform_branch_name = "main"
"@ | Out-File -FilePath .\terraform.tfvars -Force
    Write-Host "Created default tfvars file"
}

# Initialize Terraform with the new backend
Write-Host "Initializing Terraform with $Environment backend"
terraform init -reconfigure

Write-Host "`nEnvironment switched to $Environment"
Write-Host "Run 'terraform plan' to see the changes for this environment"