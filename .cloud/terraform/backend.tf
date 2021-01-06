terraform {
  backend "s3" {
    bucket  = "github-actions-in-action"
    key     = "terraform/terraform.tfstate"
    encrypt = true
    region  = "eu-west-3"
  }
}
