<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | >=5.10.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >=5.10.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 5.10.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_project_services"></a> [project\_services](#module\_project\_services) | ./modules/services | n/a |
| <a name="module_shared_vpc"></a> [shared\_vpc](#module\_shared\_vpc) | ./modules/shared_vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [google_projects.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/projects) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_network_services"></a> [app\_network\_services](#input\_app\_network\_services) | n/a | `list(string)` | n/a | yes |
| <a name="input_edge_network_services"></a> [edge\_network\_services](#input\_edge\_network\_services) | n/a | `list(string)` | n/a | yes |
| <a name="input_edge_project"></a> [edge\_project](#input\_edge\_project) | n/a | `string` | n/a | yes |
| <a name="input_vm_services"></a> [vm\_services](#input\_vm\_services) | n/a | `list(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->