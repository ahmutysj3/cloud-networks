resource "google_compute_address" "lan" {
  name         = "fw-lan-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = google_compute_subnetwork.trusted.self_link
  address      = cidrhost(google_compute_subnetwork.trusted.ip_cidr_range, 2)
}

resource "google_compute_address" "wan" {
  name         = "fw-wan-internal-ip"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  ip_version   = "IPV4"
  subnetwork   = google_compute_subnetwork.untrusted.self_link
  address      = cidrhost(google_compute_subnetwork.untrusted.ip_cidr_range, 2)
}

resource "google_compute_address" "external_lb" {
  name         = "external-lb-ip"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
  region       = var.gcp_region
}

resource "google_compute_address" "internal_lb" {
  name         = "internal-lb-ip"
  address_type = "INTERNAL"
  ip_version   = "IPV4"
  subnetwork   = google_compute_subnetwork.trusted.self_link
  purpose      = "GCE_ENDPOINT"
  region       = var.gcp_region
  address      = cidrhost(google_compute_subnetwork.trusted.ip_cidr_range, 255)

}
