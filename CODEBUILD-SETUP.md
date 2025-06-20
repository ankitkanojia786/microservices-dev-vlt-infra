# CodeBuild Setup Guide - ALR Infrastructure Pipeline

## 🚨 **Critical Setup Requirements**

### **1. CodeBuild Project Configuration**

#### **Environment Variables (REQUIRED)**
```
ENVIRONMENT = usdev-usw2
TF_COMMAND = plan
```

#### **Service Role Permissions**
Ensure CodeBuild service role has:
- `AmazonS3FullAccess` (for Terraform state)
- `AmazonDynamoDBFullAccess` (for state locking)
- `AmazonEC2FullAccess` (for VPC, subnets, etc.)
- `AmazonECSFullAccess` (for ECS resources)
- `ElasticLoadBalancingFullAccess` (for ALB)
- `AmazonSSMFullAccess` (for Parameter Store)
- `AmazonECRFullAccess` (for ECR repository)
- `IAMFullAccess` (for IAM roles)

### **2. Buildspec File Options**

#### **Option A: Simple Buildspec (Recommended)**
Use `buildspec-simple.yml` - rename to `buildspec.yml`

#### **Option B: Standard Buildspec**  
Use `buildspec-terraform.yml` - rename to `buildspec.yml`

### **3. Required Files Structure**
```
├── buildspec.yml (choose one from above)
├── backend-configs/
│   ├── usdev-usw2.hcl
│   ├── usqa-usw2.hcl
│   └── usprod-usw2.hcl
├── environments/
│   ├── usdev-usw2.tfvars
│   ├── usqa-usw2.tfvars
│   └── usprod-usw2.tfvars
└── main.tf
```

## 🔧 **CodeBuild Project Setup Steps**

### **Step 1: Create CodeBuild Project**
1. Go to AWS CodeBuild Console
2. Click "Create build project"
3. Project name: `usdev-usw2-alr-infra`

### **Step 2: Source Configuration**
- Source provider: GitHub
- Repository: `https://github.com/ankitkanojia786/microservices-dev-vlt-infra`
- Branch: `main`

### **Step 3: Environment Configuration**
- Environment image: Managed image
- Operating system: Amazon Linux 2
- Runtime: Standard
- Image: `aws/codebuild/amazonlinux2-x86_64-standard:3.0`

### **Step 4: Environment Variables**
Add these environment variables:
```
Name: ENVIRONMENT
Value: usdev-usw2

Name: TF_COMMAND  
Value: plan
```

### **Step 5: Buildspec**
- Use a buildspec file
- Buildspec name: `buildspec.yml`

### **Step 6: Service Role**
- Create new service role or use existing
- Attach required policies (see above)

## 🚀 **Testing Different Environments**

### **For Dev Environment**
```
ENVIRONMENT = usdev-usw2
TF_COMMAND = plan
```

### **For QA Environment**
```
ENVIRONMENT = usqa-usw2
TF_COMMAND = plan
```

### **For Production Environment**
```
ENVIRONMENT = usprod-usw2
TF_COMMAND = apply
```

## 🛠️ **Troubleshooting Build Failures**

### **YAML_FILE_ERROR**
- Use `buildspec-simple.yml` (rename to `buildspec.yml`)
- Avoid complex YAML structures

### **Backend Configuration Error**
- Ensure backend config file exists: `backend-configs/$ENVIRONMENT.hcl`
- Check S3 bucket permissions

### **Variable File Not Found**
- Ensure tfvars file exists: `environments/$ENVIRONMENT.tfvars`
- Check file naming matches environment variable

### **Permission Denied**
- Check CodeBuild service role has all required permissions
- Verify AWS credentials are properly configured

## 📋 **Pre-Build Checklist**

Before running pipeline:
- ✅ Environment variable `ENVIRONMENT` is set
- ✅ Environment variable `TF_COMMAND` is set  
- ✅ Backend config file exists for environment
- ✅ Tfvars file exists for environment
- ✅ CodeBuild service role has required permissions
- ✅ S3 bucket for Terraform state exists
- ✅ DynamoDB table for state locking exists

## 🎯 **Recommended Approach**

1. **Start with Simple Buildspec**: Use `buildspec-simple.yml`
2. **Test with Dev Environment**: Set `ENVIRONMENT=usdev-usw2`
3. **Use Plan First**: Always test with `TF_COMMAND=plan`
4. **Create Separate Projects**: One project per environment
5. **Manual Triggers**: Don't auto-trigger on commits initially

This setup will prevent 99% of build failures!