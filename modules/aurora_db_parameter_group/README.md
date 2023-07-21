## aurora\_db\_parameter\_group
## Purpose

It Provides an RDS DB parameter group resource.

<!-- BEGIN_TF_DOCS -->


#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

#### Resources

- resource.aws_db_parameter_group.selected (modules\aurora_db_parameter_group\main.tf#17)

#### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |

#### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tags"></a> [tags](#module\_tags) | git::https://git.rockfin.com/terraform/aws-tags-tf.git | 3.1.0 |

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | AppID of the application (from AppHub). | `string` | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The name of the application, whether it be a service, website, api, etc. | `string` | n/a | yes |
| <a name="input_development_team_email"></a> [development\_team\_email](#input\_development\_team\_email) | The development team email address that is responsible for this resource(s). | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name in which the infrastructure is located. (e.g. dev, test, beta, prod) | `string` | n/a | yes |
| <a name="input_infrastructure_engineer_email"></a> [infrastructure\_engineer\_email](#input\_infrastructure\_engineer\_email) | The infrastructure engineer email address that is responsible for this resource(s). | `string` | n/a | yes |
| <a name="input_infrastructure_team_email"></a> [infrastructure\_team\_email](#input\_infrastructure\_team\_email) | The infrastructure team email address that is responsible for this resource(s). | `string` | n/a | yes |
| <a name="input_app_tags"></a> [app\_tags](#input\_app\_tags) | Extra tags to apply to created resources | `map(string)` | `{}` | no |
| <a name="input_default_instance_parameters"></a> [default\_instance\_parameters](#input\_default\_instance\_parameters) | default customize parameter for aurora instance parameter group provided automatically for best practices. | `list(map(string))` | `[]` | no |
| <a name="input_hal_app_id"></a> [hal\_app\_id](#input\_hal\_app\_id) | ID of the Hal application | `string` | `null` | no |
| <a name="input_module_source"></a> [module\_source](#input\_module\_source) | The source of the terraform module.  Automatically populated by HAL. | `string` | `""` | no |
| <a name="input_module_version"></a> [module\_version](#input\_module\_version) | The version of the terraform module.  Automatically populated by HAL. | `string` | `""` | no |
| <a name="input_parameter_family_name"></a> [parameter\_family\_name](#input\_parameter\_family\_name) | The family of the DB cluster parameter group. This is required due to we force to use custom parameter group instead of default parameter group. | `string` | `"aurora-postgresql12"` | no |
| <a name="input_postgres_instance_parameters"></a> [postgres\_instance\_parameters](#input\_postgres\_instance\_parameters) | customize parameter for aurora instance parameter group provided by application teams. | `list(map(string))` | `[]` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Add additional prefix to beginning of resource names. | `string` | `""` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Add additional suffix to end of resource names. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | The name of the DB instance parameter group. |

<!-- END_TF_DOCS -->