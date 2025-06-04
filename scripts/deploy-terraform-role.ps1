# PowerShell script to deploy the Terraform execution role

# Parameters
param(
    [string]$Environment = "usdev-usw2",
    [string]$ProjectName = "vlt-subscription"
)

# Set AWS region
$Region = "us-west-2"

# Deploy CloudFormation stack
$StackName = "$Environment-$ProjectName-terraform-role"
Write-Host "Deploying CloudFormation stack: $StackName"

aws cloudformation deploy `
    --stack-name $StackName `
    --template-file ../cloudformation/terraform-role.yaml `
    --parameter-overrides `
        ProjectName=$ProjectName `
        Environment=$Environment `
    --capabilities CAPABILITY_NAMED_IAM `
    --region $Region

# Get outputs from CloudFormation stack
Write-Host "Getting CloudFormation stack outputs"
$Outputs = aws cloudformation describe-stacks --stack-name $StackName --region $Region | ConvertFrom-Json

# Display important information
Write-Host "`nTerraform Role Deployment Complete!`n"
Write-Host "Important Information:"
Write-Host "======================"

foreach ($Output in $Outputs.Stacks[0].Outputs) {
    Write-Host "$($Output.OutputKey): $($Output.OutputValue)"
}

# Update the buildspec file to use the role
$RoleArn = $Outputs.Stacks[0].Outputs | Where-Object { $_.OutputKey -eq "TerraformRoleArn" } | Select-Object -ExpandProperty OutputValue

Write-Host "`nTo use this role in your CodeBuild project, add the following to your buildspec.yml:"
Write-Host "environment:"
Write-Host "  variables:"
Write-Host "    TERRAFORM_ROLE_ARN: $RoleArn"
Write-Host "`nAnd add this command to your pre_build phase:"
Write-Host "- aws sts assume-role --role-arn \$TERRAFORM_ROLE_ARN --role-session-name TerraformSession > assume-role-output.json"
Write-Host "- export AWS_ACCESS_KEY_ID=\$(cat assume-role-output.json | jq -r '.Credentials.AccessKeyId')"
Write-Host "- export AWS_SECRET_ACCESS_KEY=\$(cat assume-role-output.json | jq -r '.Credentials.SecretAccessKey')"
Write-Host "- export AWS_SESSION_TOKEN=\$(cat assume-role-output.json | jq -r '.Credentials.SessionToken')"