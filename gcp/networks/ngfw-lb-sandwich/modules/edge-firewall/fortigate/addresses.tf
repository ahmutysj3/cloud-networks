# Creates the firewall inside ip
resource "google_compute_address" "lan" {
  name         = "fw-lan-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = var.subnets.trusted-subnet.self_link
  address      = cidrhost(var.subnets.trusted-subnet.ip_cidr_range, 100)
}

# Creates the firewall outside ip
resource "google_compute_address" "wan" {
  name         = "fw-internal-wan-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = var.subnets.untrusted-subnet.self_link
  address      = cidrhost(var.subnets.untrusted-subnet.ip_cidr_range, 2)
}

# Creates the external load balancer ip
resource "google_compute_address" "wan_external" {
  name         = "external-wan-ip"
  address_type = "EXTERNAL"
  region       = var.region
  project      = var.project
}

# creates the internal load balancer private ip
resource "google_compute_address" "lb_internal" {
  name         = "internal-lb-ip"
  address_type = "INTERNAL"
  region       = var.region
  project      = var.project
  subnetwork   = var.subnets.trusted-subnet.self_link
  address      = cidrhost(var.subnets.trusted-subnet.ip_cidr_range, 2)
}

resource "google_compute_address" "lb_external" {
  name         = "external-lb-ip"
  address_type = "EXTERNAL"
  region       = var.region
  project      = var.project

}
