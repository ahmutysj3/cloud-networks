output "subnets" {
  value = {
    trusted = {
      name      = google_compute_subnetwork.trusted.name
      cidr      = google_compute_subnetwork.trusted.ip_cidr_range
      self_link = google_compute_subnetwork.trusted.self_link
      gateway   = google_compute_subnetwork.trusted.gateway_address
    }
    untrusted = {
      name      = google_compute_subnetwork.untrusted.name
      cidr      = google_compute_subnetwork.untrusted.ip_cidr_range
      self_link = google_compute_subnetwork.untrusted.self_link
      gateway   = google_compute_subnetwork.untrusted.gateway_address
    }
    protected = {
      name      = google_compute_subnetwork.protected.name
      cidr      = google_compute_subnetwork.protected.ip_cidr_range
      self_link = google_compute_subnetwork.protected.self_link
      gateway   = google_compute_subnetwork.protected.gateway_address
    }
    mgmt = {
      name      = google_compute_subnetwork.mgmt.name
      cidr      = google_compute_subnetwork.mgmt.ip_cidr_range
      self_link = google_compute_subnetwork.mgmt.self_link
      gateway   = google_compute_subnetwork.mgmt.gateway_address
    }
  }
}

output "vpcs" {
  value = {
    trusted = {
      name      = google_compute_network.trusted.name
      self_link = google_compute_network.trusted.self_link
    }
    untrusted = {
      name      = google_compute_network.untrusted.name
      self_link = google_compute_network.untrusted.self_link
    }
    protected = {
      name      = google_compute_network.protected.name
      self_link = google_compute_network.protected.self_link
    }
    mgmt = {
      name      = google_compute_network.mgmt.name
      self_link = google_compute_network.mgmt.self_link
    }
  }

}
