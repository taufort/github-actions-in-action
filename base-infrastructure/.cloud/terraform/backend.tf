terraform {
  backend "s3" {
    bucket  = "github-actions-in-action"
    key     = "terraform/base-infrastructure/terraform.tfstate"
    encrypt = true
    region  = "eu-west-3"
  }
}
