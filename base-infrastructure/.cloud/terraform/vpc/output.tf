output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_name" {
  value = "${var.project}-vpc"
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

# Subnets
output "public_subnets_ids" {
  description = "Public subnets IDs list"
  value       = aws_subnet.public[*].id
}

output "private_subnets_ids" {
  description = "Internal DMZ private subnets IDs list"
  value       = aws_subnet.private[*].id
}

output "public_subnets_cidr_blocks" {
  description = "Public subnets CIDR block list"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnets_cidr_blocks" {
  description = "Internal DMZ private subnets CIDR block list"
  value       = aws_subnet.private[*].cidr_block
}

# Route tables
output "public_route_table_ids" {
  description = "Public route table IDs list"
  value       = aws_route_table.public[*].id
}

output "private_route_table_ids" {
  description = "Private route table IDs list"
  value       = aws_route_table.private[*].id
}

output "nat_gateway_eips" {
  description = "List of NAT gateway public IP"
  value       = aws_eip.nat_gateway_eip[*].public_ip
}

output "internet_gateway_id" {
  value = aws_internet_gateway.internet_gateway.id
}
