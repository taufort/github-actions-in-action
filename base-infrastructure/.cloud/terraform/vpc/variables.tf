###############################################################################
# External module params
###############################################################################
variable "cidr" {
  description = "VPC IPv4 CIDR Block"
  type        = string
}

variable "project" {
  description = "Name of the project"
  type        = string
}

variable "azs" {
  description = "Availability zones used to create subnets, only AZ letter. Region is inferred from supplied provider"
  type        = list(string)
}

variable "public_subnets" {
  description = "CIDR list of public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "CIDR list of private subnets"
  type        = list(string)
}

variable "extra_tags" {
  description = "Map of extra tag blocks added to AWS resources. Each element in the map is a pair containing a key and a value"
  type        = map(string)
  default     = {}
}

###############################################################################
# NAT Gateway configuration
###############################################################################
variable "enable_nat" {
  description = "Set to false to generate a VPC without NAT gateways"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Create one NAT gateway per AZ?"
  type        = bool
  default     = false
}
