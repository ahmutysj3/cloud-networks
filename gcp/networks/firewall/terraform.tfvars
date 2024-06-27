edge_project = "trace-vpc-edge-prod-01"

firewall_rules = [
  {
    name      = "test-firewall-ssh-rule-1"
    network   = "trace-vpc-edge-mgmt"
    project   = "trace-vpc-edge-prod-01"
    priority  = 1000
    action    = "allow"
    direction = "ingress"
    rules = [{
      ports    = ["22"]
      protocol = "tcp"
      }
    ]
    source_ranges = ["0.0.0.0/0"]
  },
  {
    name      = "test-firewall-ping-rule-1"
    network   = "trace-vpc-edge-mgmt"
    project   = "trace-vpc-edge-prod-01"
    priority  = 1000
    action    = "allow"
    direction = "ingress"
    rules = [{
      protocol = "icmp"
      }
    ]
    source_ranges = ["0.0.0.0/0"]
}]

firewall_routes = [
  {
    name             = "fw-mgmt-default-inet-route-01"
    dest_range       = "0.0.0.0/0"
    network          = "trace-vpc-edge-mgmt"
    project          = "trace-vpc-edge-prod-01"
    priority         = 0
    next_hop_gateway = "default-internet-gateway"
  },
  {
    name             = "fw-untrusted-default-inet-route-01"
    dest_range       = "0.0.0.0/0"
    network          = "trace-vpc-edge-untrusted"
    project          = "trace-vpc-edge-prod-01"
    priority         = 0
    next_hop_gateway = "default-internet-gateway"
}]
