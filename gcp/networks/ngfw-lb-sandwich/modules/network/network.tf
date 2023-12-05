# Create trusted VPC network
resource "google_compute_network" "trusted" {
  project                         = var.gcp_project
  name                            = "trusted-vpc"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

# Create untrusted VPC network
resource "google_compute_network" "untrusted" {
  project                         = var.gcp_project
  name                            = "untrusted-vpc"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
}

# Create protected VPC network
resource "google_compute_network" "protected" {
  project                         = var.gcp_project
  name                            = "protected-vpc"
  auto_create_subnetworks         = false
  delete_default_routes_on_create = true
}

# Create peering between trusted and protected VPC networks
resource "google_compute_network_peering" "trusted" {
  name                 = "trusted-to-protected-peering"
  network              = google_compute_network.trusted.self_link
  peer_network         = google_compute_network.protected.self_link
  import_custom_routes = false
  export_custom_routes = true
}

# Create peering between protected and trusted VPC networks
resource "google_compute_network_peering" "protected" {
  depends_on           = [google_compute_network_peering.trusted]
  name                 = "protected-to-trusted-peering"
  network              = google_compute_network.protected.self_link
  peer_network         = google_compute_network.trusted.self_link
  import_custom_routes = true
  export_custom_routes = false
}

# Create default route for protected VPC network going to fortigate
/* resource "google_compute_route" "protected_vpc_default" {
  name              = "protected-vpc-default-route"
  network           = google_compute_network.protected.self_link
  dest_range        = "0.0.0.0/0"
  priority          = 100
  next_hop_instance = google_compute_instance.firewall.self_link
}
 */
# Create trusted subnet
resource "google_compute_subnetwork" "trusted" {
  project       = var.gcp_project
  name          = "test-trusted-subnet"
  ip_cidr_range = local.vpc_trusted_cidr_range
  region        = var.gcp_region
  network       = google_compute_network.trusted.name
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
}

# Create untrusted subnet
resource "google_compute_subnetwork" "untrusted" {
  project                  = var.gcp_project
  name                     = "test-untrusted-subnet"
  ip_cidr_range            = local.vpc_untrusted_cidr_range
  region                   = var.gcp_region
  network                  = google_compute_network.untrusted.name
  private_ip_google_access = true
  purpose                  = "PRIVATE"
  stack_type               = "IPV4_ONLY"
}

# Create protected subnet
resource "google_compute_subnetwork" "protected" {
  project       = var.gcp_project
  name          = "test-protected-subnet"
  ip_cidr_range = local.vpc_protected_cidr_range
  region        = var.gcp_region
  network       = google_compute_network.protected.name
  purpose       = "PRIVATE"
  stack_type    = "IPV4_ONLY"
}

# Define local variables
locals {
  vpc_protected_cidr_range = "192.168.0.0/24"
  vpc_untrusted_cidr_range = "10.255.0.0/24"
  vpc_trusted_cidr_range   = "10.0.0.0/24"
}
