terraform {
  backend "s3" {
    bucket         = "usnp-usw2-terraform-microservices-statefile-bucket"
    key            = "environments/stg/terraform.tfstate"
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}