module "panorama" {
  source  = "PaloAltoNetworks/swfw-modules/google//modules/panorama"
  version = "2.0.5"

  for_each = var.panoramas

  name              = "${var.name_prefix}${each.value.panorama_name}"
  project           = var.project
  region            = var.region
  zone              = each.value.zone
  panorama_version  = each.value.panorama_version
  ssh_keys          = each.value.ssh_keys
  subnet            = data.google_compute_subnetwork.this[each.key].self_link
  private_static_ip = each.value.private_static_ip
  attach_public_ip  = each.value.attach_public_ip
  log_disks         = try(each.value.log_disks, [])
}

data "google_compute_subnetwork" "this" {
  for_each = var.panoramas
  project  = var.project
  region   = var.region
  name     = each.value.subnetwork_key
}