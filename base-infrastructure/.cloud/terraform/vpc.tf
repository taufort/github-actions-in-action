module "main_vpc" {
  source = "./vpc"

  cidr    = "10.100.0.0/24"
  project = var.tags["project"]

  azs = [
    "a",
    "b",
    "c",
  ]

  public_subnets = [
    "10.100.0.0/27",
    "10.100.0.32/27",
    "10.100.0.64/27",
  ]

  private_subnets = [
    "10.100.0.128/27",
    "10.100.0.160/27",
    "10.100.0.192/27",
  ]

  enable_nat = true

  extra_tags = var.tags
}

output "main_vpc_id" {
  value = module.main_vpc.vpc_id
}

output "main_vpc_public_subnets_ids" {
  value = module.main_vpc.public_subnets_ids
}

output "main_vpc_private_subnets_ids" {
  value = module.main_vpc.private_subnets_ids
}
