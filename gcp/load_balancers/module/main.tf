module "instance_groups" {
  source    = "./instance_groups"
  for_each  = local.instance_groups
  name      = each.value.instance_grp
  zone      = each.value.zone
  project   = var.project
  network   = data.google_compute_network.this.self_link
  instances = each.value.instances
}



