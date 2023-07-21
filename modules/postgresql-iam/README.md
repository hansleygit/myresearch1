

### Postgresql IAM module

postgresql-iam module allows users to enable features like s3Import, s3Export, Lambda, SageMaker and Comprehend for Aurora Postgresql Cluster. **DEPENDENCY NOTE**: A Lambda VPC Endpoint must be setup before enable the lambda feature. The features of 'SageMaker' and 'Comprehend' are kept as False now and will develop the code when a demand is needed in the future.

More details about these features can be found [here](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Integrating.html).

## Example Project

See example `tfvars` in the [examples](../../examples/aurora-provisioned/aurora-PostgreSQL) folder, and use it in a project following the
[terraform-starter-kit](https://git.rockfin.com/terraform/terraform-starter-kit) structure.

<!-- BEGIN_TF_DOCS -->


#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.9 |

#### Resources

- resource.aws_iam_policy.lambdapolicy (modules\postgresql-iam\main.tf#127)
- resource.aws_iam_policy.s3policy (modules\postgresql-iam\main.tf#88)
- resource.aws_iam_role.Comprehend (modules\postgresql-iam\main.tf#45)
- resource.aws_iam_role.Lambda (modules\postgresql-iam\main.tf#31)
- resource.aws_iam_role.SageMaker (modules\postgresql-iam\main.tf#38)
- resource.aws_iam_role.s3Export (modules\postgresql-iam\main.tf#24)
- resource.aws_iam_role.s3Import (modules\postgresql-iam\main.tf#15)
- resource.aws_iam_role_policy_attachment.lambda (modules\postgresql-iam\main.tf#136)
- resource.aws_iam_role_policy_attachment.s3Export_policy_attachment (modules\postgresql-iam\main.tf#105)
- resource.aws_iam_role_policy_attachment.s3Import_policy_attachment (modules\postgresql-iam\main.tf#96)
- resource.aws_rds_cluster_role_association.postgresql-iam-Comprehend (modules\postgresql-iam\main.tf#197)
- resource.aws_rds_cluster_role_association.postgresql-iam-SageMaker (modules\postgresql-iam\main.tf#211)
- resource.aws_rds_cluster_role_association.postgresql-iam-lambda (modules\postgresql-iam\main.tf#184)
- resource.aws_rds_cluster_role_association.postgresql-iam-s3export (modules\postgresql-iam\main.tf#173)
- resource.aws_rds_cluster_role_association.postgresql-iam-s3import (modules\postgresql-iam\main.tf#162)
- resource.aws_s3_bucket.import_export_data_s3 (modules\postgresql-iam\main.tf#66)
- resource.aws_s3_bucket_server_side_encryption_configuration.import_export_data_s3_encryption_config (modules\postgresql-iam\main.tf#77)
- resource.aws_security_group_rule.outbound_rule_lambda (modules\postgresql-iam\main.tf#145)
- resource.aws_security_group_rule.outbound_rule_s3 (modules\postgresql-iam\main.tf#114)
- resource.time_sleep.iam_role_propagation_wait (modules\postgresql-iam\main.tf#53)
- data source.aws_iam_policy_document.instance-assume-role-policy (modules\postgresql-iam\data.tf#1)
- data source.aws_iam_policy_document.lambda_policydoc (modules\postgresql-iam\data.tf#59)
- data source.aws_iam_policy_document.s3ImportExport (modules\postgresql-iam\data.tf#12)
- data source.aws_vpc_endpoint.lambda (modules\postgresql-iam\data.tf#70)
- data source.aws_vpc_endpoint.s3 (modules\postgresql-iam\data.tf#51)

#### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 4.0 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.9 |

#### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_tags"></a> [tags](#module\_tags) | git::https://git.rockfin.com/terraform/aws-tags-tf.git | 3.1.0 |

#### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | AppID of the application (from AppHub). | `string` | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The name of the application, whether it be a service, website, api, etc. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region in which all resources will be created. | `string` | n/a | yes |
| <a name="input_cluster_identifier"></a> [cluster\_identifier](#input\_cluster\_identifier) | cluster identifier | `string` | n/a | yes |
| <a name="input_custom_tags"></a> [custom\_tags](#input\_custom\_tags) | tags for resources | `any` | n/a | yes |
| <a name="input_db_sg_id"></a> [db\_sg\_id](#input\_db\_sg\_id) | Security group id RDS cluster | `string` | n/a | yes |
| <a name="input_development_team_email"></a> [development\_team\_email](#input\_development\_team\_email) | The development team email address that is responsible for this resource(s). | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name in which the infrastructure is located. (e.g. dev, test, beta, prod) | `string` | n/a | yes |
| <a name="input_full_app_name"></a> [full\_app\_name](#input\_full\_app\_name) | Application name - appid and environment | `string` | n/a | yes |
| <a name="input_infrastructure_engineer_email"></a> [infrastructure\_engineer\_email](#input\_infrastructure\_engineer\_email) | The infrastructure engineer email address that is responsible for this resource(s). | `string` | n/a | yes |
| <a name="input_infrastructure_team_email"></a> [infrastructure\_team\_email](#input\_infrastructure\_team\_email) | The infrastructure team email address that is responsible for this resource(s). | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Kms for encrypting S3 data | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC id RDS cluster | `string` | n/a | yes |
| <a name="input_app_tags"></a> [app\_tags](#input\_app\_tags) | Extra tags to apply to created resources | `map(string)` | `{}` | no |
| <a name="input_default_cluster_parameters"></a> [default\_cluster\_parameters](#input\_default\_cluster\_parameters) | default customize parameter for aurora cluster parameter group provided automatically for best practices. | `list(map(string))` | <pre>[<br>  {<br>    "apply_method": "immediate",<br>    "name": "rds.force_ssl",<br>    "value": "1"<br>  },<br>  {<br>    "apply_method": "immediate",<br>    "name": "ssl_min_protocol_version",<br>    "value": "TLSv1.2"<br>  }<br>]</pre> | no |
| <a name="input_engine_mode"></a> [engine\_mode](#input\_engine\_mode) | The version of aurora to run - provisioned or serverless.  Note, serverless currently only supports MySQL | `string` | `"provisioned"` | no |
| <a name="input_hal_app_id"></a> [hal\_app\_id](#input\_hal\_app\_id) | ID of the Hal application | `string` | `null` | no |
| <a name="input_lambda_arn"></a> [lambda\_arn](#input\_lambda\_arn) | The ARN of the lambdas that will be exectued through Aurora DB. | `list(string)` | `null` | no |
| <a name="input_module_source"></a> [module\_source](#input\_module\_source) | The source of the terraform module.  Automatically populated by HAL. | `string` | `""` | no |
| <a name="input_module_version"></a> [module\_version](#input\_module\_version) | The version of the terraform module.  Automatically populated by HAL. | `string` | `""` | no |
| <a name="input_pg_iam_features"></a> [pg\_iam\_features](#input\_pg\_iam\_features) | Map of features which require IAM roles for Aurora postgresql. | `map(string)` | <pre>{<br>  "Comprehend": "False",<br>  "Lambda": "False",<br>  "SageMaker": "False",<br>  "s3Export": "False",<br>  "s3Import": "False"<br>}</pre> | no |
| <a name="input_postgres_cluster_parameters"></a> [postgres\_cluster\_parameters](#input\_postgres\_cluster\_parameters) | customize parameter for aurora cluster parameter group provided by application team. | `list(map(string))` | `[]` | no |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_postgresql_iam_roles"></a> [postgresql\_iam\_roles](#output\_postgresql\_iam\_roles) | The ARN of the IAM Role. |

<!-- END_TF_DOCS -->