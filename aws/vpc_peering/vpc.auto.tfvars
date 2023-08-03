vpcs = {
  hub = {
    cidr = "10.0.0.0/16"
    type = "hub"
  }
  app = {
    cidr = "10.1.0.0/16"
    type = "spoke"
  }
  dmz = {
    cidr = "10.2.0.0/16"
    type = "spoke"
  }
  db = {
    cidr = "10.3.0.0/16"
    type = "spoke"
  }
}