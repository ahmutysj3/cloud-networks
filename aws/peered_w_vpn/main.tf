resource "aws_vpc" "hub" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "hub_vpc"
  }
}

resource "aws_subnet" "hub_outside" {
  vpc_id            = aws_vpc.hub.id
  availability_zone = data.aws_availability_zones.default.names[0]
  cidr_block        = "10.0.0.0/24"
  tags = {
    Name = "hub_outside_subnet"
  }
}

resource "aws_subnet" "hub_inside" {
  vpc_id            = aws_vpc.hub.id
  availability_zone = data.aws_availability_zones.default.names[0]
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name = "hub_inside_subnet"
  }
}

resource "aws_route_table" "hub_outside" {
  vpc_id = aws_vpc.hub.id
  tags = {
    Name = "hub_outside_route_table"
  }
}

resource "aws_route" "inet_access" {
  route_table_id         = aws_route_table.hub_outside.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.hub.id
}

resource "aws_route" "dmz_spoke" {
  route_table_id            = aws_route_table.hub_inside.id
  destination_cidr_block    = data.aws_vpc_peering_connection.hub_dmz.peer_cidr_block
  vpc_peering_connection_id = data.aws_vpc_peering_connection.hub_dmz.id
}

resource "aws_route" "app_spoke" {
  route_table_id            = aws_route_table.hub_inside.id
  destination_cidr_block    = data.aws_vpc_peering_connection.hub_app.peer_cidr_block
  vpc_peering_connection_id = data.aws_vpc_peering_connection.hub_app.id
}

resource "aws_route" "db_spoke" {
  route_table_id            = aws_route_table.hub_inside.id
  destination_cidr_block    = data.aws_vpc_peering_connection.hub_db.peer_cidr_block
  vpc_peering_connection_id = data.aws_vpc_peering_connection.hub_db.id
}

resource "aws_route_table_association" "hub_outside" {
  subnet_id      = aws_subnet.hub_outside.id
  route_table_id = aws_route_table.hub_outside.id
}

resource "aws_route_table" "hub_inside" {
  vpc_id = aws_vpc.hub.id
  tags = {
    Name = "hub_inside_route_table"
  }
}

resource "aws_route_table_association" "hub_inside" {
  subnet_id      = aws_subnet.hub_inside.id
  route_table_id = aws_route_table.hub_inside.id
}

resource "aws_internet_gateway" "hub" {
  vpc_id = aws_vpc.hub.id

  tags = {
    Name = "main_igw"
  }
}

resource "aws_vpc" "dmz" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "dmz_vpc"
  }
}

resource "aws_vpc" "app" {
  cidr_block = "10.2.0.0/16"
  tags = {
    Name = "app_vpc"
  }
}

resource "aws_vpc" "db" {
  cidr_block = "10.3.0.0/16"
  tags = {
    Name = "db_vpc"
  }
}

resource "aws_vpc_peering_connection" "hub_dmz" {
  vpc_id      = aws_vpc.hub.id
  peer_vpc_id = aws_vpc.dmz.id
  auto_accept = true
  tags = {
    Name = "hub_dmz_peering"
  }
}

resource "aws_vpc_peering_connection" "hub_app" {
  vpc_id      = aws_vpc.hub.id
  peer_vpc_id = aws_vpc.app.id
  auto_accept = true
  tags = {
    Name = "hub_app_peering"
  }
}

resource "aws_vpc_peering_connection" "hub_db" {
  vpc_id      = aws_vpc.hub.id
  peer_vpc_id = aws_vpc.db.id
  auto_accept = true
  tags = {
    Name = "hub_db_peering"
  }
}

resource "aws_subnet" "dmz1" {
  vpc_id            = aws_vpc.dmz.id
  availability_zone = data.aws_availability_zones.default.names[0]
  cidr_block        = "10.1.10.0/24"

  tags = {
    Name = "dmz1_subnet"
  }
}

resource "aws_subnet" "dmz2" {
  vpc_id            = aws_vpc.dmz.id
  availability_zone = data.aws_availability_zones.default.names[0]
  cidr_block        = "10.1.20.0/24"
  tags = {
    Name = "dmz2_subnet"
  }
}

resource "aws_subnet" "app1" {
  vpc_id            = aws_vpc.app.id
  availability_zone = data.aws_availability_zones.default.names[0]
  cidr_block        = "10.2.10.0/24"

  tags = {
    Name = "app1_subnet"
  }
}

resource "aws_subnet" "app2" {
  vpc_id            = aws_vpc.app.id
  availability_zone = data.aws_availability_zones.default.names[0]
  cidr_block        = "10.2.20.0/24"
  tags = {
    Name = "app2_subnet"
  }
}

resource "aws_subnet" "db1" {
  vpc_id            = aws_vpc.db.id
  availability_zone = data.aws_availability_zones.default.names[0]
  cidr_block        = "10.3.10.0/24"

  tags = {
    Name = "db1_subnet"
  }
}

resource "aws_subnet" "db2" {
  vpc_id            = aws_vpc.db.id
  availability_zone = data.aws_availability_zones.default.names[0]
  cidr_block        = "10.3.20.0/24"
  tags = {
    Name = "db2_subnet"
  }
}

resource "aws_route_table" "spoke_dmz" {
  vpc_id = aws_vpc.dmz.id
  tags = {
    Name = "spoke_dmz_route_table"
  }
}

resource "aws_route_table_association" "dmz1" {
  subnet_id      = aws_subnet.dmz1.id
  route_table_id = aws_route_table.spoke_dmz.id
}

resource "aws_route_table_association" "dmz2" {
  subnet_id      = aws_subnet.dmz2.id
  route_table_id = aws_route_table.spoke_dmz.id
}

resource "aws_route_table" "spoke_app" {
  vpc_id = aws_vpc.app.id
  tags = {
    Name = "spoke_app_route_table"
  }
}

resource "aws_route_table_association" "app1" {
  subnet_id      = aws_subnet.app1.id
  route_table_id = aws_route_table.spoke_app.id
}

resource "aws_route_table_association" "app2" {
  subnet_id      = aws_subnet.app2.id
  route_table_id = aws_route_table.spoke_app.id
}

resource "aws_route_table" "spoke_db" {
  vpc_id = aws_vpc.db.id
  tags = {
    Name = "spoke_db_route_table"
  }
}

resource "aws_route_table_association" "db1" {
  subnet_id      = aws_subnet.db1.id
  route_table_id = aws_route_table.spoke_db.id
}

resource "aws_route_table_association" "db2" {
  subnet_id      = aws_subnet.db2.id
  route_table_id = aws_route_table.spoke_db.id
}
