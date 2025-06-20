bucket         = "usnp-usw2-terraform-microservices-statefile-bucket"
key            = "alr/usqa-usw2/infra-pipeline/terraform.tfstate"
region         = "us-west-2"
encrypt        = true
dynamodb_table = "terraform-state-lock"