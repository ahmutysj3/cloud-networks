variable "project" {
  type = string
}

variable "web_subnets" {
  type = map(string)
}

variable "vpcs" {
  type = map(object({
    name      = string
    self_link = string
    id        = string
  }))
}

variable "zones" {
  type = list(string)
}
