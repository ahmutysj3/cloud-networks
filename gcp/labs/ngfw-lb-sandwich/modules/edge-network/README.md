<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >=5.9 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >=5.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >=5.9 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_peerings"></a> [peerings](#module\_peerings) | ./peerings | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_network.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_router.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router) | resource |
| [google_compute_router_nat.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_router_nat) | resource |
| [google_compute_subnetwork.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_client_config.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ip_block"></a> [ip\_block](#input\_ip\_block) | n/a | `string` | n/a | yes |
| <a name="input_log_config"></a> [log\_config](#input\_log\_config) | n/a | `map(string)` | <pre>{<br>  "enable": true,<br>  "filter": "ERRORS_ONLY"<br>}</pre> | no |
| <a name="input_nat_ip_allocate_option"></a> [nat\_ip\_allocate\_option](#input\_nat\_ip\_allocate\_option) | n/a | `string` | `"AUTO_ONLY"` | no |
| <a name="input_router"></a> [router](#input\_router) | n/a | `bool` | n/a | yes |
| <a name="input_source_subnetwork_ip_ranges_to_nat"></a> [source\_subnetwork\_ip\_ranges\_to\_nat](#input\_source\_subnetwork\_ip\_ranges\_to\_nat) | n/a | `string` | `"ALL_SUBNETWORKS_ALL_IP_RANGES"` | no |
| <a name="input_spoke_vpcs"></a> [spoke\_vpcs](#input\_spoke\_vpcs) | n/a | `map(string)` | n/a | yes |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_gateway"></a> [gateway](#output\_gateway) | n/a |
| <a name="output_ip_addr"></a> [ip\_addr](#output\_ip\_addr) | n/a |
| <a name="output_network"></a> [network](#output\_network) | n/a |
| <a name="output_subnet"></a> [subnet](#output\_subnet) | n/a |
<!-- END_TF_DOCS -->