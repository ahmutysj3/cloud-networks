variable "gcp_project" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "web_subnets" {
  type = list(string)
}
