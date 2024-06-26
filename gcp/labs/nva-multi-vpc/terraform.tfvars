config = {
  region     = "us-east1"
  project_id = "trace-terraform-perm"
}

fw_networks = {
  untrusted = "10.0.0.0/24"
  mgmt      = "10.0.1.0/24"
  ha        = "10.0.2.0/24"
  trusted   = "10.0.3.0/24"
}
