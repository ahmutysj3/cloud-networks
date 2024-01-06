app_network_services = [
  "servicenetworking.googleapis.com",
  "compute.googleapis.com",
  "storage-component.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "logging.googleapis.com",
  "firewallinsights.googleapis.com",
  "networkconnectivity.googleapis.com",
  "networkmanagement.googleapis.com",
  "networksecurity.googleapis.com",
  "networkservices.googleapis.com",
]
edge_network_services = [
  "servicenetworking.googleapis.com",
  "compute.googleapis.com",
  "certificatemanager.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "secretmanager.googleapis.com",
  "logging.googleapis.com",
  "firewallinsights.googleapis.com",
  "networkconnectivity.googleapis.com",
  "networkmanagement.googleapis.com",
  "networksecurity.googleapis.com",
  "networkservices.googleapis.com",
]
vm_services = [
  "compute.googleapis.com",
  "storage-component.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "replicapool.googleapis.com",        # create and manage instance groups
  "replicapoolupdater.googleapis.com", # rolling updates for instance groups
  "deploymentmanager.googleapis.com",
  "cloudshell.googleapis.com",
  "oslogin.googleapis.com",
  "resourceviews.googleapis.com", # allows grouping of instances into igs
  "networkconnectivity.googleapis.com",
]

edge_project = "trace-vpc-edge"
vm_project   = "trace-app-vm"
