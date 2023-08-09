
resource "aws_instance" "pfsense" {
    depends_on = [ aws_subnet.hub_outside ]
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
  }
  
}

resource "aws_network_interface" "pfsense_outside" {
    depends_on = [ aws_subnet.hub_outside ]
  subnet_id       = aws_subnet.hub_outside.id
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