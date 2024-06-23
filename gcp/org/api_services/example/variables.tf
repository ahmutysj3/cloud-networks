variable "edge_network_services" {
  type = list(string)
}

variable "app_network_services" {
  type = list(string)
}

variable "gke_project_services" {
  type = list(string)
}

variable "vm_services" {
  type = list(string)
}

variable "project_names" {
  type = map(string)
}
