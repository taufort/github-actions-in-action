###############################################################################
# Default resources management
# Terraform does not create these resources, but instead "adopts" them into management
###############################################################################
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id
  // No rule is defined in default security group.
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.main.default_network_acl_id

  subnet_ids = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    { Name = "${var.project}-default-acl" },
    var.extra_tags
  )
}

resource "aws_default_vpc_dhcp_options" "default" {
  tags = merge(
    { Name = "Default AWS DHCP Option Set" },
    var.extra_tags
  )
}
