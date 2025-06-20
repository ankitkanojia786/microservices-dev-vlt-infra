# Environment Variables Configuration

## **Required Environment Variables for CodeBuild**

### **Non-Production Environments (Dev, QA, Staging)**
Use single S3 bucket: `alr-nonprod-terraform-state`

#### **Development Environment**
```
STATE_FILE_BUCKET = alr-nonprod-terraform-state
STATE_FILE_PATH = dev/alr-infra/terraform.tfstate
REGION = us-west-2
DB_TABLE = terraform-state-lock
TF_VAR = ../tfvars-file/usdev-usw2.tfvars
```

#### **QA Environment**
```
STATE_FILE_BUCKET = alr-nonprod-terraform-state
STATE_FILE_PATH = qa/alr-infra/terraform.tfstate
REGION = us-west-2
DB_TABLE = terraform-state-lock
TF_VAR = ../tfvars-file/usqa-usw2.tfvars
```

#### **Staging Environment**
```
STATE_FILE_BUCKET = alr-nonprod-terraform-state
STATE_FILE_PATH = stg/alr-infra/terraform.tfstate
REGION = us-west-2
DB_TABLE = terraform-state-lock
TF_VAR = ../tfvars-file/usstg-usw2.tfvars
```

### **Production Environment**
Use separate S3 bucket: `alr-prod-terraform-state`

#### **Production Environment**
```
STATE_FILE_BUCKET = alr-prod-terraform-state
STATE_FILE_PATH = prod/alr-infra/terraform.tfstate
REGION = us-west-2
DB_TABLE = terraform-state-lock-prod
TF_VAR = ../tfvars-file/usprod-usw2.tfvars
```

#### **Beta Environment**
```
STATE_FILE_BUCKET = alr-prod-terraform-state
STATE_FILE_PATH = beta/alr-infra/terraform.tfstate
REGION = us-west-2
DB_TABLE = terraform-state-lock-prod
TF_VAR = ../tfvars-file/usbeta-usw2.tfvars
```

## **S3 Bucket Structure**

### **Non-Production Bucket: `alr-nonprod-terraform-state`**
```
alr-nonprod-terraform-state/
├── dev/
│   └── alr-infra/
│       └── terraform.tfstate
├── qa/
│   └── alr-infra/
│       └── terraform.tfstate
└── stg/
    └── alr-infra/
        └── terraform.tfstate
```

### **Production Bucket: `alr-prod-terraform-state`**
```
alr-prod-terraform-state/
├── prod/
│   └── alr-infra/
│       └── terraform.tfstate
└── beta/
    └── alr-infra/
        └── terraform.tfstate
```

## **CodeBuild Project Setup**

### **Create Separate Projects:**

1. **alr-infra-dev** (Development)
2. **alr-infra-qa** (QA)
3. **alr-infra-stg** (Staging)
4. **alr-infra-prod** (Production)
5. **alr-infra-beta** (Beta)

Each project should have its respective environment variables configured.

## **Benefits of This Approach**

✅ **Single S3 bucket for non-prod** (cost-effective)  
✅ **Separate S3 bucket for prod** (security isolation)  
✅ **Environment-specific state files** (no conflicts)  
✅ **No hardcoded backend configs** (fully variablized)  
✅ **Easy to manage and scale** (add new environments easily)