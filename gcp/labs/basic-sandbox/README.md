# Basic GCP Network Sandbox

- deploys a quick and dirty network with a subnet and allow all firewall rule applied globally

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
| <a name="provider_google"></a> [google](#provider\_google) | >=5.9 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_network.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ip_cidr_range"></a> [ip\_cidr\_range](#input\_ip\_cidr\_range) | ip cidr range | `string` | `"10.0.0.0/24"` | no |
| <a name="input_project"></a> [project](#input\_project) | The project to create the instance in | `string` | `""` | no |
| <a name="input_region"></a> [region](#input\_region) | The region to create the instance in | `string` | `""` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | name of the subnet | `string` | `"test-subnet"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | name of the vpc | `string` | `"test-vpc"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->