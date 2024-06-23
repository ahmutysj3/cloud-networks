variable "timeouts" {
  description = "values for project service deployment timeouts"
  type        = map(string)
  default = {
    create = "30m"
    update = "40m"
  }
}

variable "disable_dependent_services" {
  description = "whether or not to disable dependent services if destroying"
  type        = bool
  default     = true
}

variable "project_names" {
  description = "role names for the projects"
  type        = map(string)
  default     = {}
}

variable "host_project" {
  description = "value of the host project id"
  type        = string
  default     = ""
}

variable "project_ids" {
  description = "map of project id values to project name"
  type        = map(string)
  default     = {}
}

variable "service_projects" {
  description = "list of projects that will be able to use the shared vpc"
  type        = list(string)
  default     = []
}

variable "vm_services" {
  description = "services to enable in vm instance project"
  type        = list(string)
  default     = []
}

variable "edge_network_services" {
  description = "services to enable in edge network project"
  type        = list(string)
  default     = []
}

variable "app_network_services" {
  description = "services to enable in app network project"
  type        = list(string)
  default     = []
}

variable "gke_project_services" {
  type    = list(string)
  default = []
}
