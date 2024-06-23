variable "projects" {
  type = list(object({
    name   = string
    folder = optional(string)
  }))
  default = []
}

variable "root_folders" {
  type = list(object({
    name   = string
    parent = string
  }))
  default = []
}

variable "sub_folders" {
  type = list(object({
    name   = string
    parent = string
  }))
  default = []
}

variable "gcp_perm_project" {
  type    = string
  default = ""
}

variable "gcp_billing_account" {
  type    = string
  default = ""
}

variable "gcp_domain" {
  type    = string
  default = ""
}
