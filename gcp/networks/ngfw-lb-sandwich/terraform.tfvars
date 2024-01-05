image_project = "trace-vpc-edge"
edge_project  = "trace-vpc-edge"
prod_project  = "trace-vpc-app-prod"
dev_project   = "trace-vpc-app-dev"
bu1_project   = "trace-vm-business-unit1"
bu2_project   = "trace-vm-business-unit2"



gcp_region       = "us-east1"
deploy_fortigate = false
edge_vpcs = {
  untrusted = {
    cidr    = "10.255.0.0/24"
    project = "trace-vpc-edge"
  }
  trusted = {
    cidr    = "10.0.0.0/24"
    project = "trace-vpc-edge"
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
