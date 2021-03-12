terraform {
  backend "s3" {
    bucket  = "github-actions-in-action"
    key     = "terraform/gateway/10_ecr/terraform.tfstate"
    encrypt = true
    region  = "eu-west-3"
  }
}
