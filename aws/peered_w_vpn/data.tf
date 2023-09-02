data "aws_vpc_peering_connection" "hub_dmz" {
  depends_on  = [aws_vpc_peering_connection.hub_dmz]
  vpc_id      = aws_vpc.hub.id
  peer_vpc_id = aws_vpc.dmz.id
  status      = "active"
}

data "aws_vpc_peering_connection" "hub_app" {
  depends_on  = [aws_vpc_peering_connection.hub_app]
  vpc_id      = aws_vpc.hub.id
  peer_vpc_id = aws_vpc.app.id
  status      = "active"
}

data "aws_vpc_peering_connection" "hub_db" {
  depends_on  = [aws_vpc_peering_connection.hub_db]
  vpc_id      = aws_vpc.hub.id
  peer_vpc_id = aws_vpc.db.id
  status      = "active"
}

data "aws_ami" "pfsense" {
  most_recent = true
  name_regex  = "pfSense-plus-ec2-23.05-RELEASE-amd64"
  owners      = ["aws-marketplace"]

  filter {
    name   = "boot-mode"
    values = ["uefi"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "default" {
  state = "available"
}