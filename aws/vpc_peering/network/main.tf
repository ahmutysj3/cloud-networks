# builds VPCs based on var.vpcs inputs - default is 1 x Hub VPC and 3 x Spoke VPCs
resource "aws_vpc" "main" {
  for_each         = var.vpcs
  cidr_block       = each.value.cidr
  instance_tenancy = "default"

  tags = {
    Name = "${each.key}_vpc"
    type = each.value.type
  }
}

# local variables for the hub VPC cidr and id
locals {
  hub_id   = element([for vpck, vpc in aws_vpc.main : vpc.id if vpc.tags.type == "hub"], 0)
  hub_cidr = element([for vpck, vpc in aws_vpc.main : vpc.cidr_block if vpc.tags.type == "hub"], 0)
}

# builds 1 x IGW for the hub VPC
resource "aws_internet_gateway" "hub" {
  vpc_id = local.hub_id
  tags = {
    Name = "hub_igw"
  }
}

# builds a subnet for inside interface of firewall
resource "aws_subnet" "hub" {
  for_each                = { "trusted" = 0, "untrusted" = 1, "mgmt" = 2 }
  vpc_id                  = local.hub_id
  cidr_block              = cidrsubnet(local.hub_cidr, 8, each.value)
  map_public_ip_on_launch = each.value < 1 ? false : true
  tags = {
    Name = "hub_${each.key}_subnet"
  }
}


# builds the spoke subnets based on inputs within var.spoke_subnets
resource "aws_subnet" "spoke" {
  for_each                = var.spoke_subnets
  vpc_id                  = aws_vpc.main[each.value.vpc_id].id
  cidr_block              = each.value.cidr
  map_public_ip_on_launch = each.key == "dmz" || each.key == "hub" ? true : false
  tags = {
    type = "spoke"
    Name = "${each.key}_subnet"
  }
}

# peers each spoke VPC to the hub VPC
resource "aws_vpc_peering_connection" "main" {
  for_each = {
    for vpck, vpc in aws_vpc.main : vpck => vpc if vpc.tags.type == "spoke"
  }
  peer_vpc_id = aws_vpc.main[each.key].id
  vpc_id      = local.hub_id
  auto_accept = true

  tags = {
    Name = "${each.key}_vpc_peering"
  }
}

# builds a security group that allows all inbound and outbound traffic
resource "aws_security_group" "allow_all" {
  for_each    = aws_vpc.main
  name        = "allow_all_sg"
  description = "Allow all inbound/outbound traffic"
  vpc_id      = aws_vpc.main[each.key].id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "all"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# builds a security group for each spoke VPC
resource "aws_security_group" "spokes" {
  for_each = {
    for vpck, vpc in aws_vpc.main : vpck => vpc if vpc.tags.type == "spoke"
  }
  name        = "${each.key}_nsg"
  description = "Network Security Group for ${each.key} VPC"
  vpc_id      = aws_vpc.main[each.key].id
}

# builds a rule for each sg allowing outbound to hub vpc
resource "aws_security_group_rule" "spoke_egress" {
  for_each = {
    for vpck, vpc in aws_vpc.main : vpck => vpc if vpc.tags.type == "spoke"
  }
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  security_group_id = aws_security_group.spokes[each.key].id
  cidr_blocks       = [aws_vpc.main["hub"].cidr_block]
}

# builds a rule for each sg allowing inbound from hub vpc 
resource "aws_security_group_rule" "spoke_ingress" {
  for_each = {
    for vpck, vpc in aws_vpc.main : vpck => vpc if vpc.tags.type == "spoke"
  }
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  security_group_id = aws_security_group.spokes[each.key].id
  cidr_blocks       = [aws_vpc.main["hub"].cidr_block]
}

# builds sg rule allowing outbound to app vpc
resource "aws_security_group_rule" "dmz_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  security_group_id = aws_security_group.spokes["dmz"].id
  cidr_blocks       = [aws_vpc.main["app"].cidr_block]
}

# builds sg rule allowing outbound to dmz or db VPCs
resource "aws_security_group_rule" "app_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  security_group_id = aws_security_group.spokes["app"].id
  cidr_blocks       = [aws_vpc.main["db"].cidr_block, aws_vpc.main["dmz"].cidr_block]
}

# builds sg rule allowing outbound to app VPC
resource "aws_security_group_rule" "db_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  security_group_id = aws_security_group.spokes["db"].id
  cidr_blocks       = [aws_vpc.main["app"].cidr_block]
}

# builds sg rule allowing inbound from app db and self
resource "aws_security_group_rule" "dmz_ingress" {
  for_each = {
    for vpck, vpc in aws_vpc.main : vpck => vpc if vpc.tags.type == "spoke" && vpck != "db"
  }
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  security_group_id = aws_security_group.spokes["dmz"].id
  cidr_blocks       = [aws_vpc.main[each.key].cidr_block]
}

# builds sg rule allowing inbound from any spoke vpc including self
resource "aws_security_group_rule" "app_ingress" {
  for_each = {
    for vpck, vpc in aws_vpc.main : vpck => vpc if vpc.tags.type == "spoke"
  }
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  security_group_id = aws_security_group.spokes["app"].id
  cidr_blocks       = [aws_vpc.main[each.key].cidr_block]
}

# builds sg rule allowing inbound from app vpc and self
resource "aws_security_group_rule" "db_ingress" {
  for_each = {
    for vpck, vpc in aws_vpc.main : vpck => vpc if vpc.tags.type == "spoke" && vpck != "dmz"
  }
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "all"
  security_group_id = aws_security_group.spokes["db"].id
  cidr_blocks       = [aws_vpc.main[each.key].cidr_block]
}

# DEV ONLY NACL
# creates a default allow all out/allow ssh in nacl in each VPC

/* resource "aws_network_acl" "main" {
  for_each = aws_vpc.main
  vpc_id   = aws_vpc.main[each.key].id

  egress {
    protocol   = "all"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  tags = {
    Name = "${each.key}_main_acl"
  }
} */

# associates the default VPC nacl to each subnet
/* resource "aws_network_acl_association" "main" {
  for_each       = var.spoke_subnets
  network_acl_id = aws_network_acl.main[each.value.vpc_id].id
  subnet_id      = aws_subnet.spoke[each.key].id
} */

# creates a route table for the hub untrusted subnet
resource "aws_route_table" "hub" {
  for_each = aws_subnet.hub
  vpc_id   = aws_subnet.hub[each.key].vpc_id

  # each.key == "trusted" to only apply to hub_trusted_subnet
  dynamic "route" {
    iterator = vpc_rr

    for_each = [
      for vpck, vpc in aws_vpc.main :
      {
        cidr        = aws_vpc.main[vpck].cidr_block,
        vpc_peer_id = aws_vpc_peering_connection.main[vpck].id
      }
      if vpc.tags.type == "spoke" && each.key == "trusted"
    ]

    content {
      cidr_block                = vpc_rr.value.cidr
      vpc_peering_connection_id = vpc_rr.value.vpc_peer_id
    }
  }

  tags = {
    Name = "hub_${each.key}_main_rt"
  }

  # each.key == "untrusted" to only apply to hub_untrusted_subnet
  dynamic "route" {
    iterator = vpc_rr

    for_each = [
      for vpck, vpc in aws_vpc.main :
      {
        cidr        = aws_vpc.main[vpck].cidr_block,
        vpc_peer_id = aws_vpc_peering_connection.main[vpck].id
      }
      if vpc.tags.type == "spoke" && each.key == "untrusted"
    ]

    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.hub.id
    }
  }
}

# associates hub route tables to their subnets
resource "aws_route_table_association" "hub" {
  for_each       = aws_subnet.hub
  subnet_id      = aws_subnet.hub[each.key].id
  route_table_id = aws_route_table.hub[each.key].id
}

#
#
####
// Note: Need to add another route pointing to pfsense instance once it is deployed
####
#
#


# creates a default route table in each spoke VPC and points all traffic to the peering w/ hub VPC
resource "aws_default_route_table" "spokes" {
  for_each = {
    for vpck, vpc in aws_vpc.main : vpck => vpc if vpc.tags.type == "spoke"
  }
  default_route_table_id = aws_vpc.main[each.key].default_route_table_id

  route {
    cidr_block                = "0.0.0.0/0"
    vpc_peering_connection_id = aws_vpc_peering_connection.main[each.key].id
  }

  tags = {
    Name = "spoke_${each.key}_main_rt"
  }
}



