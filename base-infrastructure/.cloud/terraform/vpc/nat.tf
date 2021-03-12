###############################################################################
# NAT Gateway
###############################################################################
resource "aws_eip" "nat_gateway_eip" {
  count = var.enable_nat ? var.one_nat_gateway_per_az ? length(var.public_subnets) : 1 : 0
  vpc   = true

  tags = merge(
    { Name = "${var.project}:nat-gateway-eip-${aws_subnet.public[count.index].availability_zone}" },
    var.extra_tags
  )
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.enable_nat ? var.one_nat_gateway_per_az ? length(var.public_subnets) : 1 : 0
  allocation_id = aws_eip.nat_gateway_eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    { Name = "${var.project}:nat-gateway-${aws_subnet.public[count.index].availability_zone}" },
    var.extra_tags
  )

  depends_on = [
    aws_internet_gateway.internet_gateway
  ]
}

###############################################################################
# Routes
###############################################################################
resource "aws_route" "private_to_nat_gateway_route" {
  count = var.enable_nat ? length(var.private_subnets) : 0

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.one_nat_gateway_per_az ? aws_nat_gateway.nat_gateway[count.index].id : aws_nat_gateway.nat_gateway[0].id
}
