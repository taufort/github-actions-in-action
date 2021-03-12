module "gateway_ecr" {
  source = "./ecr"
  name   = "${var.tags["project"]}/${var.application}"
  tags   = var.tags
}

output "gateway_ecr_repository_url" {
  value = module.gateway_ecr.ecr_repository_url
}
