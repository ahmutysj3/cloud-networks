image_project    = "trace-terraform-perm"
edge_project     = "trace-vpc-edge"
prod_vpc_project = "trace-vpc-app-prod-410520"

gcp_region = "us-east1"

edge_vpcs = {
  untrusted = {
    cidr   = "10.255.0.0/24"
    router = true
  }
  mgmt = {
    cidr   = "10.0.0.0/24"
    router = true
  }
  trusted = {
    cidr   = "10.0.1.0/24"
    router = false
  }
  ha = {
    cidr   = "10.0.2.0/24"
    router = false
  }
}

fw_public_interface = "mgmt"

spoke_vpcs = {
  app = {
    cidr    = "192.168.0.0/17"
    project = "trace-vpc-app-prod-410520"
  }
  db = {
    cidr    = "192.168.128.0/17"
    project = "trace-vpc-app-prod-410520"
  }
}

spoke_subnets = ["application", "database", "management"]

trace_ssh_public_key = "trace:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjI2kHRd2kAMmb8wbVmu66q/MfHhGiop6tZ1s7e9iJ+TzOK0S92cfIxrBTu08J6MhTg/CUfZwHe6WKB3sA5A2tWOLLpYdkvvwAojOh0z7hD9l8UZ57agRu0aaVfOofQwhQBWZFiOWIOUWmLAtHCxejV24ICJt/+pk1D+0MhqulKccC1Si7RZgzBqGzeH64mwgTbbl/QD3Hf2NcT5PvUZL9yWJDonoh1CZ5j4SfU/YJBBQXXsI3LJkH5gGCz2+CY+ZhZbtnCLrDMsgzK9uUSamdZ7bIiBi0LAM8P9O+QK75kBwnyRvQly92sIP50uxMGAfI8D/MfmHoP9pcTmHFbWcv trace@trace-laptop"
