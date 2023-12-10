# Creates the firewall inside ip
resource "google_compute_address" "lan" {
  name         = "fw-lan-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = var.subnets.trusted.self_link
  address      = cidrhost(var.subnets.trusted.cidr, 2)
}

# Creates the firewall outside ip
resource "google_compute_address" "wan" {
  name         = "fw-wan-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = var.subnets.untrusted.self_link
  address      = cidrhost(var.subnets.untrusted.cidr, 2)
}

# Creates the external load balancer ip
resource "google_compute_address" "lb_external" {
  name         = "external-lb-ip"
  address_type = "EXTERNAL"
  region       = var.gcp_region
  project      = var.gcp_project
}

# creates the internal load balancer private ip
resource "google_compute_address" "lb_internal" {
  name         = "internal-lb-ip"
  address_type = "INTERNAL"
  region       = var.gcp_region
  project      = var.gcp_project
  subnetwork   = var.subnets.trusted.self_link
  address      = cidrhost(var.subnets.trusted.cidr, 3)
}

resource "google_compute_address" "mgmt_internal" {
  name         = "fw-mgmt-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = var.subnets.mgmt.self_link
  address      = cidrhost(var.subnets.mgmt.cidr, 3)
}

resource "google_compute_address" "mgmt_external" {
  name         = "fw-mgmt-external-ip"
  address_type = "EXTERNAL"
  region       = var.gcp_region
  project      = var.gcp_project
}
