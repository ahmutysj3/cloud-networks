/* machine_type    = "e2-micro"
instance_name   = "trace-test-instance"
gcp_region      = "us-east1"
vm_project      = "trace-vm-instance-410520"
tags            = ["allow-all-lb-hc", "allow-iap-ssh-rdp", "allow-all"]
network_project = "trace-vpc-app-prod-410520"
vpc_name        = "app-vpc"
subnetwork_name = "app-vpc-application-subnet" */



machine_type    = "e2-micro"
instance_name   = "trace-test-instance"
gcp_region      = "us-east1"
vm_project      = "trace-terraform-perm"
tags            = ["allow-all"]
network_project = "trace-terraform-perm"
subnetwork_name = "test-subnet"
vpc_name        = "test-vpc"
