subnet_params = {
  fwinside = {
    cidr = "10.0.0.0/24"
    vpc = "hub"
  }
  fwoutside = {
    cidr = "10.0.255.0/24"
    vpc = "hub"
  }
  app1 = {
    cidr = "10.10.1.0/24"
    vpc  = "app"
  },
  app2 = {
    cidr = "10.10.2.0/24"
    vpc  = "app"
  },
  db1 = {
    cidr = "10.20.1.0/24"
    vpc  = "db"
  },
  db2 = {
    cidr = "10.20.2.0/24"
    vpc  = "db"
  },
  dmz1 = {
    cidr = "10.30.1.0/24"
    vpc  = "dmz"
  },
  dmz2 = {
    cidr = "10.30.2.0/24"
    vpc  = "dmz"
  }
}

vpc_params = {
  hub = {
    make_this_hub_vpc       = true
    default_routes          = false
  }
  app = {
    make_this_hub_vpc       = false
    default_routes          = false
  }
  db = {
    make_this_hub_vpc       = false
    default_routes          = false
  }
  dmz = {
    make_this_hub_vpc       = false
    default_routes          = false
  }
}
