resource "google_compute_firewall" "fw_mgmt" {
  name        = "firewall-web-gui-access"
  network     = google_compute_network.mgmt.name
  description = "Allow web gui access to FortiGate mgmt interface"
  direction   = "INGRESS"

  allow {
    protocol = "icmp"
  }

  allow { # web gui access
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-fgt"]

}

resource "google_compute_firewall" "fw_untrusted" {
  name        = "firewall-perimeter-access"
  network     = google_compute_network.untrusted.name
  description = "allow all to the wan/outside interface of the FortiGate"
  direction   = "INGRESS"

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["allow-fgt"]

}

resource "google_compute_firewall" "ha_sync" {
  name        = "firewall-heartbeat-sync"
  network     = google_compute_network.ha_sync.name
  description = "allow all traffic within heartbeat sync network"
  direction   = "INGRESS"

  allow {
    protocol = "all"
  }

  source_ranges = [google_compute_subnetwork.fw_ha_sync.ip_cidr_range]
  target_tags   = ["allow-fgt"]

}

resource "google_compute_firewall" "trusted" {
  name        = "firewall-trusted-access"
  network     = google_compute_network.trusted.name
  description = "allow all traffic from the trusted network"
  direction   = "INGRESS"

  allow {
    protocol = "all"
  }

  source_ranges = [google_compute_subnetwork.fw_trusted.ip_cidr_range]
  target_tags   = ["allow-fgt"]

}