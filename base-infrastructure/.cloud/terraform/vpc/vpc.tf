data "aws_region" "current" {
}

###############################################################################
# VPC
###############################################################################
resource "aws_vpc" "main" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    { Name = "${var.project}-vpc" },
    var.extra_tags
  )
}

###############################################################################
# Subnets
###############################################################################
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = "${data.aws_region.current.name}${var.azs[count.index]}"
  map_public_ip_on_launch = true

  tags = merge(
    { Name = "${var.project}-public-subnet-${data.aws_region.current.name}${var.azs[count.index]}" },
    { tier = "public" },
    var.extra_tags
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnets[count.index]
  availability_zone       = "${data.aws_region.current.name}${var.azs[count.index]}"
  map_public_ip_on_launch = false

  tags = merge(
    { Name = "${var.project}-private-subnet-${data.aws_region.current.name}${var.azs[count.index]}" },
    { tier = "private" },
    var.extra_tags
  )
}

###############################################################################
# Internet Gateways
###############################################################################
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    { Name = "${var.project}-internet-gateway" },
    var.extra_tags
  )
}

###############################################################################
# Route tables
###############################################################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    { Name = "${var.project}-public-route-table" },
    var.extra_tags
  )
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}

resource "aws_route_table" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.main.id

  tags = merge(
    { Name = "${var.project}-private-route-table-${aws_subnet.private[count.index].availability_zone}" },
    var.extra_tags
  )
}

###############################################################################
# Route table associations
###############################################################################
resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
