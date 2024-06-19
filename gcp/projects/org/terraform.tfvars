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
  "dns.googleapis.com",
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
  "dns.googleapis.com",
]
vm_services = [
  "compute.googleapis.com",
  "storage-component.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "certificatemanager.googleapis.com", # for SSL certs for https load balancers
  "replicapool.googleapis.com",        # create and manage instance groups
  "replicapoolupdater.googleapis.com", # rolling updates for instance groups
  "deploymentmanager.googleapis.com",
  "cloudshell.googleapis.com",
  "oslogin.googleapis.com",
  "resourceviews.googleapis.com", # allows grouping of instances into igs
  "networkconnectivity.googleapis.com",
]

gke_project_services = [
  "servicenetworking.googleapis.com",
  "compute.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  "logging.googleapis.com",
  "networksecurity.googleapis.com",
  "networkservices.googleapis.com",
  "container.googleapis.com",
  "containersecurity.googleapis.com",
]

project_names = {
  app_vpc = "trace-vpc-app-prod"
  edge    = "trace-vpc-edge"
  vm      = "trace-vm-instance"
  gke     = "trace-gke-project"
}
