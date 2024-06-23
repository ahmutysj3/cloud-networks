# Organization & Project Services Module

- this module sets up the shared vpc infra and enables services in the projects

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google-beta_google_compute_shared_vpc_host_project.this](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_shared_vpc_host_project) | resource |
| [google-beta_google_compute_shared_vpc_service_project.this](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_compute_shared_vpc_service_project) | resource |
| [google_project_service.app](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.edge](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.gke](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_project_service.vm](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_network_services"></a> [app\_network\_services](#input\_app\_network\_services) | services to enable in app network project | `list(string)` | `[]` | no |
| <a name="input_disable_dependent_services"></a> [disable\_dependent\_services](#input\_disable\_dependent\_services) | whether or not to disable dependent services if destroying | `bool` | `true` | no |
| <a name="input_edge_network_services"></a> [edge\_network\_services](#input\_edge\_network\_services) | services to enable in edge network project | `list(string)` | `[]` | no |
| <a name="input_host_project"></a> [host\_project](#input\_host\_project) | value of the host project id | `string` | `""` | no |
| <a name="input_project_ids"></a> [project\_ids](#input\_project\_ids) | map of project id values to project name | `map(string)` | `{}` | no |
| <a name="input_project_names"></a> [project\_names](#input\_project\_names) | role names for the projects | `map(string)` | `{}` | no |
| <a name="input_service_projects"></a> [service\_projects](#input\_service\_projects) | list of projects that will be able to use the shared vpc | `list(string)` | `[]` | no |
| <a name="input_timeouts"></a> [timeouts](#input\_timeouts) | values for project service deployment timeouts | `map(string)` | <pre>{<br>  "create": "30m",<br>  "update": "40m"<br>}</pre> | no |
| <a name="input_vm_services"></a> [vm\_services](#input\_vm\_services) | services to enable in vm instance project | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->