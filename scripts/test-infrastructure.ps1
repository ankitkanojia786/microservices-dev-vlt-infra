# Infrastructure Testing Script
param(
    [Parameter(Mandatory=$true)]
    [string]$Environment
)

Write-Host "=== ALR Infrastructure Testing ===" -ForegroundColor Green
Write-Host "Environment: $Environment" -ForegroundColor Yellow

# Test 1: Validate Terraform configuration
Write-Host "`n1. Validating Terraform configuration..." -ForegroundColor Cyan
terraform validate
if ($LASTEXITCODE -ne 0) {
    Write-Error "Terraform validation failed"
    exit 1
}
Write-Host "✓ Configuration is valid" -ForegroundColor Green

# Test 2: Check formatting
Write-Host "`n2. Checking Terraform formatting..." -ForegroundColor Cyan
terraform fmt -check
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Code is properly formatted" -ForegroundColor Green
} else {
    Write-Host "⚠ Code formatting issues found" -ForegroundColor Yellow
}

# Test 3: Test AWS connectivity
Write-Host "`n3. Testing AWS connectivity..." -ForegroundColor Cyan
$identity = aws sts get-caller-identity 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ AWS credentials are valid" -ForegroundColor Green
    $identity | ConvertFrom-Json | Format-Table
} else {
    Write-Error "AWS credentials not configured"
    exit 1
}

# Test 4: Check if VPC exists
Write-Host "`n4. Checking if VPC exists..." -ForegroundColor Cyan
$vpc = aws ec2 describe-vpcs --filters "Name=tag:Name,Values=$Environment-vpc" --region us-west-2 2>$null
if ($LASTEXITCODE -eq 0) {
    $vpcData = $vpc | ConvertFrom-Json
    if ($vpcData.Vpcs.Count -gt 0) {
        Write-Host "✓ VPC $Environment-vpc found" -ForegroundColor Green
        Write-Host "  VPC ID: $($vpcData.Vpcs[0].VpcId)" -ForegroundColor Gray
    } else {
        Write-Error "VPC $Environment-vpc not found"
        exit 1
    }
} else {
    Write-Error "Failed to check VPC"
    exit 1
}

# Test 5: Test S3 backend access
Write-Host "`n5. Testing S3 backend access..." -ForegroundColor Cyan
aws s3 ls s3://usnp-usw2-terraform-microservices-statefile-bucket/ 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ S3 backend bucket accessible" -ForegroundColor Green
} else {
    Write-Error "S3 backend bucket not accessible"
    exit 1
}

# Test 6: Terraform plan (dry run)
Write-Host "`n6. Running Terraform plan (dry run)..." -ForegroundColor Cyan
terraform plan -var-file="environments/$Environment.tfvars" -detailed-exitcode
$planResult = $LASTEXITCODE

switch ($planResult) {
    0 { Write-Host "✓ No changes needed" -ForegroundColor Green }
    1 { Write-Error "Terraform plan failed"; exit 1 }
    2 { Write-Host "✓ Plan successful - changes detected" -ForegroundColor Green }
}

Write-Host "`n=== All Tests Passed ===" -ForegroundColor Green
Write-Host "Infrastructure is ready for deployment!" -ForegroundColor Green