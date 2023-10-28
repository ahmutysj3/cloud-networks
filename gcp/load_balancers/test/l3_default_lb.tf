
resource "google_compute_region_backend_service" "test" {
  name                  = "test-backend-l3"
  project               = "terraform-project-trace-lab"
  region                = "us-east1"
  load_balancing_scheme = "INTERNAL"
  health_checks         = [google_compute_region_health_check.test.self_link]
  session_affinity      = "CLIENT_IP"
  protocol              = "UNSPECIFIED"

  backend {
    group    = google_compute_instance_group.test.self_link
    failover = false
  }
}

resource "google_compute_region_health_check" "test" {
  name    = "test-health-check"
  project = "terraform-project-trace-lab"
  region  = "us-east1"

  tcp_health_check {
    port = 22
  }
}

resource "google_compute_forwarding_rule" "test" {
  name                  = "test-fwd-rule"
  region                = "us-east1"
  project               = "terraform-project-trace-lab"
  ip_protocol           = "L3_DEFAULT"
  load_balancing_scheme = "INTERNAL"
  subnetwork            = "projects/terraform-project-trace-lab/regions/us-east1/subnetworks/protected-subnet"
  all_ports             = true
  backend_service       = google_compute_region_backend_service.test.self_link

}

resource "google_compute_instance_group" "test" {
  name    = "test-instance-group"
  project = "terraform-project-trace-lab"
  zone    = "us-east1-b"
  network = data.google_compute_network.test.self_link

}

data "google_compute_network" "test" {
  project = "terraform-project-trace-lab"
  name    = "protected-network"
}
