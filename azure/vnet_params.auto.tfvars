vnet_params = {
  hub = {
    cidr = "10.1.0.0/16"
  }
  app = {
    cidr = "10.3.0.0/16"
  }
  dmz = {
    cidr = "10.2.0.0/16"
  }
  db = {
    cidr = "10.4.0.0/16"
  }
}

subnet_params = {

  load_balancer = {
    vnet     = "dmz"
    cidr     = "10.2.10.0/24"
    flow_log = false
  }

  vpn_access = {
    vnet     = "dmz"
    cidr     = "10.2.20.0/24"
    flow_log = false

  }

  vault = {
    vnet     = "app"
    cidr     = "10.3.10.0/24"
    flow_log = false

  }

  hosting = {
    vnet     = "app"
    cidr     = "10.3.20.0/24"
    flow_log = false

  }

  mysql = {
    vnet     = "db"
    cidr     = "10.4.10.0/24"
    flow_log = false

  }

  mariadb = {
    vnet     = "db"
    cidr     = "10.4.20.0/24"
    flow_log = false

  }

}

