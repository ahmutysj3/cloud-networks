locals {
  routes = yamldecode(file("${path.module}/fw.routes.yml"))["routes"]
  rules  = yamldecode(file("${path.module}/fw.rules.yml"))["rules"]
}

module "firewall" {
  source = "../"

  edge_project    = var.edge_project
  firewall_rules  = local.rules
  firewall_routes = local.routes
}
