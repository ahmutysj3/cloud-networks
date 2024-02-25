<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | 1.6.3 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >=5.9 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >=5.9 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.17.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_edge_network_services"></a> [edge\_network\_services](#module\_edge\_network\_services) | ./modules/edge-network | n/a |
| <a name="module_firewall"></a> [firewall](#module\_firewall) | ./modules/edge-firewall | n/a |
| <a name="module_spoke_vpcs"></a> [spoke\_vpcs](#module\_spoke\_vpcs) | ./modules/app-networks | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_network.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_compute_subnetwork.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_subnetwork) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_edge_project"></a> [edge\_project](#input\_edge\_project) | n/a | `string` | n/a | yes |
| <a name="input_edge_vpcs"></a> [edge\_vpcs](#input\_edge\_vpcs) | n/a | `map(any)` | n/a | yes |
| <a name="input_firewall_model"></a> [firewall\_model](#input\_firewall\_model) | n/a | `string` | n/a | yes |
| <a name="input_gcp_region"></a> [gcp\_region](#input\_gcp\_region) | n/a | `string` | n/a | yes |
| <a name="input_image_project"></a> [image\_project](#input\_image\_project) | n/a | `string` | n/a | yes |
| <a name="input_prod_vpc_project"></a> [prod\_vpc\_project](#input\_prod\_vpc\_project) | n/a | `string` | n/a | yes |
| <a name="input_spoke_subnets"></a> [spoke\_subnets](#input\_spoke\_subnets) | n/a | `list(string)` | n/a | yes |
| <a name="input_spoke_vpcs"></a> [spoke\_vpcs](#input\_spoke\_vpcs) | n/a | `map(any)` | n/a | yes |
| <a name="input_trace_ssh_public_key"></a> [trace\_ssh\_public\_key](#input\_trace\_ssh\_public\_key) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->