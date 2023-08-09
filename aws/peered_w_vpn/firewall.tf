
resource "aws_instance" "pfsense" {
  ami = data.aws_ami.pfsense.id
  availability_zone = data.aws_availability_zones.default.names[0]
  instance_type = "t3.nano"
  private_ip = cidrhost(aws_subnet.hub_inside.cidr_block,4)
  subnet_id = aws_subnet.hub_inside.id
  tags = {
    Name = "pfsense"
  }
  key_name = aws_key_pair.pfsense.key_name

  cpu_options {
    core_count = 1
    threads_per_core = 2
  }

  
}

resource "aws_network_interface" "pfsense_outside" {
    description = "firewall-wan-nic"
    depends_on = [ aws_subnet.hub_outside ]
  subnet_id       = aws_subnet.hub_outside.id
  private_ips = [cidrhost(aws_subnet.hub_outside.cidr_block,4)]
  tags = {
    Name = "pfsense_outside_nic"
  }

  attachment {
    instance = aws_instance.pfsense.id
    device_index = 1
  }
}

resource "aws_key_pair" "pfsense" {
  key_name = "deploy"
  public_key = file("~/.ssh/id_rsa.pub")
  tags = {
    Name = "vmbox-ubuntu-key"
  }
}