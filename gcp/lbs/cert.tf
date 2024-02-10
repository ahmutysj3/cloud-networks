resource "google_compute_managed_ssl_certificate" "this" {
  name = "test-cert"

  managed {
    domains = ["test.tracecloud.us"]
  }
}
