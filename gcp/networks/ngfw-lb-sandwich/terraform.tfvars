image_project = "trace-terraform-"
edge_project  = "trace-vpc-edge"

gcp_region = "us-east1"

edge_vpcs = {
  untrusted = {
    cidr    = "10.255.0.0/24"
    project = "trace-vpc-edge"
    router  = true
  }
  trusted = {
    cidr    = "10.0.0.0/24"
    project = "trace-vpc-edge"
    router  = false
  }
}

spoke_vpcs = {
  prod = {
    cidr    = "192.168.0.0/17"
    project = "trace-vpc-app-prod"
  }
  dev = {
    cidr    = "192.168.128.0/17"
    project = "trace-vpc-app-dev"
  }
}
