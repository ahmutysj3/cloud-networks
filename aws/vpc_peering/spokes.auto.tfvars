spoke_subnets = {
  primary = {
    vpc_id = "app"
    cidr   = "10.1.1.0/24"
    mgmt   = false
  }
  hosting = {
    vpc_id = "app"
    cidr   = "10.1.2.0/24"
    mgmt   = false
  }
  openvpn = {
    vpc_id = "dmz"
    cidr   = "10.2.1.0/24"
    mgmt   = false
  }
  nginx = {
    vpc_id = "dmz"
    cidr   = "10.2.2.0/24"
    mgmt   = false
  }
  vault = {
    vpc_id = "db"
    cidr   = "10.3.1.0/24"
    mgmt   = false
  }
  mysql = {
    vpc_id = "db"
    cidr   = "10.3.2.0/24"
    mgmt   = false
  }
  mgmt1 = {
    vpc_id = "app"
    cidr   = "10.1.3.0/24"
    mgmt   = true
  }
  mgmt2 = {
    vpc_id = "dmz"
    cidr   = "10.2.3.0/24"
    mgmt   = true
  }
  mgmt3 = {
    vpc_id = "db"
    cidr   = "10.3.3.0/24"
    mgmt   = true
  }
}
