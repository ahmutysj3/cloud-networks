data "aws_vpc_peering_connection" "hub_dmz" {
  depends_on  = [aws_vpc_peering_connection.hub_dmz]
  vpc_id      = aws_vpc.hub.id
  peer_vpc_id = aws_vpc.dmz.id
}

data "aws_vpc_peering_connection" "hub_app" {
  depends_on  = [aws_vpc_peering_connection.hub_app]
  vpc_id      = aws_vpc.hub.id
  peer_vpc_id = aws_vpc.app.id
}

data "aws_vpc_peering_connection" "hub_db" {
  depends_on  = [aws_vpc_peering_connection.hub_db]
  vpc_id      = aws_vpc.hub.id
  peer_vpc_id = aws_vpc.db.id
}

data "aws_ami" "pfsense" {
  most_recent      = true
  name_regex       = "pfSense-plus-ec2-23.05-RELEASE-amd64"
  owners           = ["aws-marketplace"]

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

resource "aws_instance" "pfsense" {
  ami = data.aws_ami.pfsense.id
  availability_zone = data.aws_availability_zones.default.names[0]
  instance_type = "t3.nano"
  tags = {
    Name = "pfsense"
  }
  key_name = aws_key_pair.pfsense.key_name

  cpu_options {
    core_count = 1
    threads_per_core = 2
  }
  
  network_interface {
    network_interface_id = aws_network_interface.pfsense_outside.id
    device_index = 0
    network_card_index =   0
  }
}

resource "aws_network_interface" "pfsense_outside" {
  subnet_id       = aws_subnet.hub_outside.id
  private_ip     = cidrhost(aws_subnet.hub_outside.cidr_block,3)
  tags = {
    Name = "pfsense_outside_nic"
  }
}

resource "aws_key_pair" "pfsense" {
  key_name = "deploy"
  public_key = file("~/.ssh/id_rsa.pub")
  tags = {
    Name = "vmbox-ubuntu-key"
  }
}