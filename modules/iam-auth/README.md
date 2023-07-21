
> :warning: **DISCLAIMER** **The IAM DB authentication only can be enabled on Aurora Provisioned and Aurora Global clusters and it is not supported with Aurora Serverless at the time of this writing.**

## Purpose

You can authenticate to your DB cluster using AWS Identity and Access Management (IAM) database authentication. With this authentication method, you don't need to use a password when you connect to a DB cluster. Instead, you use an authentication token.
By default, IAM database authentication is disabled on DB cluster.  You need to enable it (setup var.iam\_database\_authentication\_enabled = true) first before running this module. Here is the instruction for enabling IAM database authentication: https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.IAMDBAuth.Enabling.html. When setting this value to true, a role will be created with the name `"${local.environment}-${var.app_id}-${var.application_name}"` for provisioned and  `"${var.aws_region}-${local.environment}-${var.app_id}-${var.application_name}"` for global.


> :warning: Once you setup IAM DB Authetication on your master username, then you cannot use your password to connect to database. You have to use token instead. Below are the instructions how to generate the token to connect to your database for Aurora PostgreSQL:
- To enable IAM DB Auth on your current master user (example: root), run below script to grant the rds_iam role to your master user. Refer to here https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.IAMDBAuth.DBAccounts.html#UsingWithRDS.IAMDBAuth.DBAccounts.PostgreSQL 
  GRANT rds_Iam TO root;
- Using IAM authentication to connect with pgAdmin Amazon Aurora PostgreSQL or Amazon RDS for PostgreSQL: https://aws.amazon.com/blogs/database/using-iam-authentication-to-connect-with-pgadmin-amazon-aurora-postgresql-or-amazon-rds-for-postgresql/  
- Example code for setup IAM DB authentication: https://git.rockfin.com/DBECore/iam-rds-auth-testing/tree/master/postgreSQL
    

- More details are available here, https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/UsingWithRDS.IAMDBAuth.html

## Availability for IAM database authentication
- Aurora PostgreSQL
    - All Aurora PostgreSQL 13 versions
    - All Aurora PostgreSQL 12 versions
    - All Aurora PostgreSQL 11.6 and higher 11 versions
    - All Aurora PostgreSQL 10.11 and higher 10 versions
    - All Aurora PostgreSQL 9.6.16 and higher 9.6 versions

## Example Project

See example `tfvars` in the [examples](../../examples) directory, and use it in a project following the
[terraform-starter-kit](https://git.rockfin.com/terraform/terraform-starter-kit) structure.

<!-- BEGIN_TF_DOCS -->


#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.9 |

#### Resources

- resource.aws_iam_policy.iam-dbauth-policy (modules\iam-auth\main.tf#39)
- resource.aws_iam_role.iam-dbauth-role (modules\iam-auth\main.tf#22)
- resource.aws_iam_role_policy_attachment.iam-dbauth-role-attachment (modules\iam-auth\main.tf#76)
- resource.time_sleep.iam_role_propagation_wait (modules\iam-auth\main.tf#31)
- data source.aws_iam_policy_document.iam-dbauth-assume (modules\iam-auth\main.tf#61)
- data source.aws_iam_policy_document.iam-dbauth-document (modules\iam-auth\main.tf#46)

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
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | Core ID of the application. | `string` | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The name of the application, whether it be a service, website, api, etc. | `string` | n/a | yes |
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | The AWS account to deploy into. | `string` | n/a | yes |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region in which all resources will be created. | `string` | n/a | yes |
| <a name="input_development_team_email"></a> [development\_team\_email](#input\_development\_team\_email) | development\_team\_email | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name in which the infrastructure is located. (e.g. dev, test, beta, prod) | `string` | n/a | yes |
| <a name="input_iam_role_name"></a> [iam\_role\_name](#input\_iam\_role\_name) | The Name of IAM role | `string` | n/a | yes |
| <a name="input_infrastructure_engineer_email"></a> [infrastructure\_engineer\_email](#input\_infrastructure\_engineer\_email) | infrastructure\_engineer\_email | `string` | n/a | yes |
| <a name="input_infrastructure_team_email"></a> [infrastructure\_team\_email](#input\_infrastructure\_team\_email) | infrastructure\_team\_email | `string` | n/a | yes |
| <a name="input_app_tags"></a> [app\_tags](#input\_app\_tags) | hal app tags | `map(string)` | `{}` | no |
| <a name="input_cluster_resource_id"></a> [cluster\_resource\_id](#input\_cluster\_resource\_id) | The region-unique, immutable identifier for the DB cluster. | `list(string)` | `[]` | no |
| <a name="input_db_user_name"></a> [db\_user\_name](#input\_db\_user\_name) | The database user name, could be more than one here. | `list(string)` | `[]` | no |
| <a name="input_engine_mode"></a> [engine\_mode](#input\_engine\_mode) | The version of aurora to run - provisioned or serverless. | `string` | `"provisioned"` | no |
| <a name="input_hal_app_id"></a> [hal\_app\_id](#input\_hal\_app\_id) | ID of the Hal application | `string` | `null` | no |
| <a name="input_module_source"></a> [module\_source](#input\_module\_source) | The source of the terraform module.  Automatically populated by HAL. | `string` | `null` | no |
| <a name="input_module_version"></a> [module\_version](#input\_module\_version) | The version of the terraform module being used.  Automatically populated by HAL. | `string` | `null` | no |

#### Outputs

No outputs.

<!-- END_TF_DOCS -->