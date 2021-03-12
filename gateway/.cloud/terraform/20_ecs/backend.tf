terraform {
  backend "s3" {
    bucket  = "github-actions-in-action"
    key     = "terraform/gateway/20_ecs/terraform.tfstate"
    encrypt = true
    region  = "eu-west-3"
  }
}
