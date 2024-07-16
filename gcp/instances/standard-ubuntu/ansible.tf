provider "ansible" {
}

resource "ansible_group" "ubuntu" {
  name = "ubuntu"

  variables = {
    ansible_ssh_private_key_file = "~/.ssh/id_rsa"
    ansible_user                 = "ubuntu"
  }
}

resource "ansible_host" "this" {
  depends_on = [data.google_compute_instance.this]
  for_each   = local.ansible_target_ips
  name       = each.key
  groups     = [ansible_group.ubuntu.name]

  variables = {
    ansible_host = each.value
  }
}

resource "ansible_playbook" "playbook" {
  for_each = { for k, v in ansible_host.this : v.name => v if contains(v.groups, ansible_group.ubuntu.name) }
  playbook                = "playbooks/playbook.yml"
  name                    = ansible_host.this[each.key].variables.ansible_host
  replayable              = true
  ansible_playbook_binary = "ansible-playbook"
  verbosity               = 1
  groups                  = [ansible_group.ubuntu.name]

  extra_vars = ansible_group.ubuntu.variables
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
    },
    {
      vm_project = "network-edge-infra-dr-sandbox"
      vm_name    = "standard-ubuntu-3"
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

