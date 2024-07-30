provider "ansible" {
}

resource "ansible_playbook" "playbook" {
  for_each = { for k, v in local.ansible_targets : v.vm_name => v }
  playbook                = "playbooks/playbook.yml"
  name                    = each.value.vm_name
  replayable              = true
  ansible_playbook_binary = "ansible-playbook"
  verbosity               = 1
  groups                  = null

  extra_vars = {
    ansible_host = local.ansible_target_ips[each.key]
    ansible_ssh_private_key_file = "~/.ssh/id_rsa"
  }
}

locals {
  ansible_targets = [
    {
      vm_project = "network-edge-infra-dr-sandbox"
      vm_name    = "standard-ubuntu-1"
      vm_zone    = "us-east4-a"
    },
    {
      vm_project = "network-edge-infra-dr-sandbox"
      vm_name    = "standard-ubuntu-2"
      vm_zone    = "us-east4-a"
    }
  ]
  ansible_target_ips = { for k, v in data.google_compute_instance.this : v.name => v.network_interface[0].access_config[0].nat_ip }

}
data "google_compute_instance" "this" {
  depends_on = [google_compute_instance.this]
  for_each   = { for k, v in local.ansible_targets : v.vm_name => v }

  project = each.value.vm_project
  name    = each.value.vm_name
  zone    = each.value.vm_zone
}

