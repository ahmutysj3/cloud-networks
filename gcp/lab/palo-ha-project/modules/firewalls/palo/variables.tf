variable "name" {
  type = string
}

variable "region" {
  type = string
}

variable "project_id" {
  type = string
}

variable "interfaces" {
  type = any

}

variable "compute_params" {
  type = map(string)
}

variable "disk_params" {
  type = map(string)
}
