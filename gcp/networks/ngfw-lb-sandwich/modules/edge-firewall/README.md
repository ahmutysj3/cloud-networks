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
| <a name="module_load_balancers"></a> [load\_balancers](#module\_load\_balancers) | ./load-balancers | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_address.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_disk.firewall_boot](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_instance.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_compute_instance_group.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_group) | resource |
| [google_client_config.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config) | data source |
| [google_compute_default_service_account.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_default_service_account) | data source |
| [google_compute_image.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_params"></a> [address\_params](#input\_address\_params) | ip address params | `map(string)` | <pre>{<br>  "address_type": "EXTERNAL",<br>  "ip_version": "IPV4"<br>}</pre> | no |
| <a name="input_fw_network_interfaces"></a> [fw\_network\_interfaces](#input\_fw\_network\_interfaces) | n/a | <pre>list(object({<br>    vpc     = string<br>    subnet  = string<br>    ip_addr = string<br>    gateway = string<br>  }))</pre> | n/a | yes |
| <a name="input_gui_port"></a> [gui\_port](#input\_gui\_port) | n/a | `number` | n/a | yes |
| <a name="input_lb_types"></a> [lb\_types](#input\_lb\_types) | n/a | `list(string)` | <pre>[<br>  "ilb",<br>  "elb"<br>]</pre> | no |
| <a name="input_model"></a> [model](#input\_model) | n/a | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->