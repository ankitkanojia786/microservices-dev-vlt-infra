bucket         = "eunp-euw1-terraform-microservices-statefile-bucket"
key            = "alr/eudev-euw1/infra-pipeline/terraform.tfstate"
region         = "eu-west-1"
encrypt        = true
dynamodb_table = "terraform-state-lock"