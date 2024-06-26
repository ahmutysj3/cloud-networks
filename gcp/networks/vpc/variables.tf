variable "default_network_params" {
  type = object({
    auto_create_subnetworks         = bool
    routing_mode                    = string
    delete_default_routes_on_create = bool
  })
  default = {
    auto_create_subnetworks         = false
    routing_mode                    = "GLOBAL"
    delete_default_routes_on_create = true
  }
}
