# Firewall VPC
data "aws_subnets" "spoke_vpc" {
  for_each = aws_vpc.spoke

  filter {
    name   = "vpc-id"
    values = [each.value.id]
  }
}

resource "aws_vpc" "firewall" {
  cidr_block = cidrsubnet(var.supernet_cidr, 7, 127)

  tags = {
    Name = "${var.network_prefix}_firewall_vpc"
    type = "firewall"
  }
}

# Firewall VPC Subnets
resource "aws_subnet" "firewall" {
  for_each                = { for index, subnet in var.firewall_defaults.subnets : subnet => index }
  vpc_id                  = aws_vpc.firewall.id
  cidr_block              = each.key == "tgw" ? cidrsubnet(aws_vpc.firewall.cidr_block, 1, 1) : cidrsubnet(aws_vpc.firewall.cidr_block, 3, each.value)
  map_public_ip_on_launch = false #each.key == "outside" ? true : false
  availability_zone       = var.availability_zone_list[0]

  tags = {
    Name     = "${var.network_prefix}_fw_${each.key}_subnet"
    rt_table = each.key == "outside" || each.key == "mgmt" ? "external" : each.key == "inside" || each.key == "heartbeat" ? "internal" : "tgw"
    type     = "firewall"
  }
}

# Firewall VPC Internet Gateway
resource "aws_internet_gateway" "main" {
  tags = {
    Name = "${var.network_prefix}_igw"
  }
}

resource "aws_internet_gateway_attachment" "main" {
  internet_gateway_id = aws_internet_gateway.main.id
  vpc_id              = aws_vpc.firewall.id
}

# Firewall VPC Security Group
resource "aws_security_group" "firewall" {
  name        = "Firewall Allow-All Security Group"
  description = "Allow all traffic to/from the Internet"
  vpc_id      = aws_vpc.firewall.id


  ingress {
    description = "Allow inbound traffic from the Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic to the Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.network_prefix}_fw_sg"
  }
}

# Firewall VPC Route Tables
resource "aws_route_table" "firewall" {
  for_each = toset(var.firewall_defaults.rt_tables)
  vpc_id   = aws_vpc.firewall.id

  tags = {
    Name = "${var.network_prefix}_fw_${each.key}_rt_table"
  }
}

# Firewall External Route Table Associations
resource "aws_route_table_association" "firewall" {
  for_each       = { for index, subnet in var.firewall_defaults.subnets : subnet => index }
  subnet_id      = aws_subnet.firewall[each.key].id
  route_table_id = aws_route_table.firewall[aws_subnet.firewall[each.key].tags.rt_table].id
}

# Firewall VPC TGW Route Table Routes
resource "aws_route" "tgw_spoke" {
  for_each               = var.spoke_vpc_params
  route_table_id         = aws_route_table.firewall["tgw"].id
  destination_cidr_block = each.value.cidr_block
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}

resource "aws_route" "tgw_to_fw_inside" {
  route_table_id         = aws_route_table.firewall["tgw"].id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_network_interface.firewall["inside"].id
}

resource "aws_route" "firewall" {
  for_each               = toset(["internal", "external"])
  route_table_id         = aws_route_table.firewall[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = each.key == "external" ? aws_internet_gateway.main.id : null
  transit_gateway_id     = each.key == "internal" ? aws_ec2_transit_gateway.main.id : null
}

# Spoke VPCs
resource "aws_vpc" "spoke" {
  for_each   = var.spoke_vpc_params
  cidr_block = each.value.cidr_block
  tags = {
    Name = "${var.network_prefix}_${each.key}_vpc"
    type = "spoke"
  }
}

# Spoke Subnets
locals {
  vpc_subnet_map        = { for k, v in var.spoke_vpc_params : k => v.subnets }
  vpc_subnet_map_values = flatten(values(transpose(local.vpc_subnet_map)))
  vpc_subnet_map_keys   = keys(transpose(local.vpc_subnet_map))
  subnet_to_vpc_map     = zipmap(local.vpc_subnet_map_keys, local.vpc_subnet_map_values)
}

resource "aws_subnet" "spoke" { # creates a /24 subnet for each entry in the subnets argument for var.spoke_vpc_params
  for_each                = local.subnet_to_vpc_map
  cidr_block              = cidrsubnet(aws_vpc.spoke[each.value].cidr_block, 24 - element(split("/", aws_vpc.spoke[each.value].cidr_block), 1), lookup(zipmap(lookup(local.vpc_subnet_map, each.value), range(length(lookup(local.vpc_subnet_map, each.value)))), each.key))
  vpc_id                  = aws_vpc.spoke[each.value].id
  map_public_ip_on_launch = false
  availability_zone       = var.availability_zone_list[0]

  tags = {
    Name = "${each.key}_subnet"
    type = "spoke"
  }
}


# Spoke & Firewall VPCs - Allow-All ACLs
resource "aws_network_acl_association" "main" {
  for_each       = merge(aws_subnet.firewall, aws_subnet.spoke)
  network_acl_id = aws_network_acl.main[each.key].id
  subnet_id      = each.value.id
}

resource "aws_network_acl" "main" {
  for_each = merge(aws_subnet.firewall, aws_subnet.spoke)
  vpc_id   = each.value.vpc_id

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.network_prefix}_${each.key}_acl"
  }
}

# Spoke VPC Route Tables
resource "aws_route_table" "spoke" {
  for_each = aws_vpc.spoke
  vpc_id   = each.value.id

  tags = {
    Name = "${each.key}_route_table"
  }
}

# Subnet VPC Route Table Associations
resource "aws_route_table_association" "spoke" {
  for_each       = aws_subnet.spoke
  subnet_id      = each.value.id
  route_table_id = aws_route_table.spoke[lookup(local.subnet_to_vpc_map, each.key)].id
}

# Subnet VPC Routes
resource "aws_route" "spoke" {
  for_each               = aws_route_table.spoke
  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = aws_ec2_transit_gateway.main.id
}