variable "gcp_project" {
  type = string
}

variable "gcp_region" {
  type = string
}

variable "web_subnets" {
  type = list(string)
}

variable "zones" {
  type = list(string)

}

variable "vpcs" {
  type = map(object({
    name      = string
    self_link = string
    id        = string
  }))
}
