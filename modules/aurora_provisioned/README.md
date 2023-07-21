### Aurora Provisioned module

aurora\_provisioned module allows users to create a Aurora PostgreSQL-compatible relational database built for the cloud that combines the performance and availability of traditional enterprise databases with the simplicity and cost-effectiveness of open source databases. Amazon Aurora can help to improve reliability and availability of the database. Amazon Aurora being a fully managed service helps you save time by automating time consuming tasks such as provisioning, patching, backup, recovery, failure detection, and repair.

More details about their features can be found [here](https://www.amazonaws.cn/en/rds/aurora/).

## Example Project

See example `tfvars` in the [examples](../../examples/aurora-provisioned) folder, and use it in a project following the
[terraform-starter-kit](https://git.rockfin.com/terraform/terraform-starter-kit) structure.

<!-- BEGIN_TF_DOCS -->


#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

#### Resources

- resource.aws_cloudwatch_log_group.cluster_cloudwatch_log_group (modules\aurora_provisioned\main.tf#211)
- resource.aws_db_subnet_group.cluster (modules\aurora_provisioned\main.tf#162)
- resource.aws_iam_role.enhanced_monitoring_role (modules\aurora_provisioned\main.tf#67)
- resource.aws_iam_role_policy_attachment.enhanced_monitoring_role_attachment (modules\aurora_provisioned\main.tf#92)
- resource.aws_rds_cluster.cluster_with_encryption_provisioned (modules\aurora_provisioned\main.tf#14)
- resource.aws_rds_cluster_instance.cluster_instances (modules\aurora_provisioned\main.tf#107)
- resource.aws_security_group.cluster (modules\aurora_provisioned\main.tf#178)
- resource.aws_security_group_rule.allow_connections_from_cidr_blocks (modules\aurora_provisioned\main.tf#185)
- resource.aws_security_group_rule.allow_connections_from_security_group (modules\aurora_provisioned\main.tf#196)
- data source.aws_caller_identity.current (modules\aurora_provisioned\main.tf#64)
- data source.aws_iam_policy_document.enhanced_monitoring_role (modules\aurora_provisioned\main.tf#79)
- data source.aws_iam_role.auto_created_monitoring_role_arn (modules\aurora_provisioned\main.tf#102)
- data source.aws_region.current (modules\aurora_provisioned\main.tf#61)

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
| <a name="input_allow_connections_from_cidr_blocks"></a> [allow\_connections\_from\_cidr\_blocks](#input\_allow\_connections\_from\_cidr\_blocks) | A list of CIDR-formatted IP address ranges that can connect to this DB. In the standard Gruntwork VPC setup, these should be the CIDR blocks of the private app subnets, plus the private subnets in the mgmt VPC. | `list(string)` | n/a | yes |
| <a name="input_app_id"></a> [app\_id](#input\_app\_id) | AppID of the application (from AppHub). | `string` | n/a | yes |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The name of the application, whether it be a service, website, api, etc. | `string` | n/a | yes |
| <a name="input_development_team_email"></a> [development\_team\_email](#input\_development\_team\_email) | The development team email address that is responsible for this resource(s). | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name in which the infrastructure is located. (e.g. dev, test, beta, prod) | `string` | n/a | yes |
| <a name="input_infrastructure_engineer_email"></a> [infrastructure\_engineer\_email](#input\_infrastructure\_engineer\_email) | The infrastructure engineer email address that is responsible for this resource(s). | `string` | n/a | yes |
| <a name="input_infrastructure_team_email"></a> [infrastructure\_team\_email](#input\_infrastructure\_team\_email) | The infrastructure team email address that is responsible for this resource(s). | `string` | n/a | yes |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | How many instances to launch. RDS will automatically pick a leader and configure the others as replicas. | `number` | n/a | yes |
| <a name="input_master_password"></a> [master\_password](#input\_master\_password) | The password for the master user. If var.snapshot\_identifier is non-empty, this value is ignored. | `string` | n/a | yes |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | The username for the master user. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name used to namespace all resources created by these templates, including the cluster and cluster instances (e.g. drupaldb). Must be unique in this region. Must be a lowercase string. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet ids where the database instances should be deployed. In the standard Gruntwork VPC setup, these should be the private persistence subnet ids. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The id of the VPC in which this DB should be deployed. | `string` | n/a | yes |
| <a name="input_allow_connections_from_security_groups"></a> [allow\_connections\_from\_security\_groups](#input\_allow\_connections\_from\_security\_groups) | Specifies a list of Security Groups to allow connections from. | `list(string)` | `[]` | no |
| <a name="input_app_tags"></a> [app\_tags](#input\_app\_tags) | Extra tags to apply to created resources | `map(string)` | `{}` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Note that cluster modifications may cause degraded performance or downtime. | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. | `bool` | `false` | no |
| <a name="input_aws_db_security_group_description"></a> [aws\_db\_security\_group\_description](#input\_aws\_db\_security\_group\_description) | The description of the aws\_db\_security\_group that is created. Defaults to 'Security group for the var.name DB' if not specified. | `string` | `null` | no |
| <a name="input_aws_db_security_group_name"></a> [aws\_db\_security\_group\_name](#input\_aws\_db\_security\_group\_name) | The name of the aws\_db\_security\_group that is created. Defaults to var.name if not specified. | `string` | `null` | no |
| <a name="input_aws_db_subnet_group_description"></a> [aws\_db\_subnet\_group\_description](#input\_aws\_db\_subnet\_group\_description) | The description of the aws\_db\_subnet\_group that is created. Defaults to 'Subnet group for the var.name DB' if not specified. | `string` | `null` | no |
| <a name="input_aws_db_subnet_group_name"></a> [aws\_db\_subnet\_group\_name](#input\_aws\_db\_subnet\_group\_name) | The name of the aws\_db\_subnet\_group that is created. Defaults to var.name if not specified. | `string` | `null` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | How many days to keep backup snapshots around before cleaning them up | `number` | `null` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | The identifier of the CA certificate for the DB instance. | `string` | `"rds-ca-rsa2048-g1"` | no |
| <a name="input_custom_tags"></a> [custom\_tags](#input\_custom\_tags) | A map of custom tags to apply to the Aurora RDS Instance and the Security Group created for it. The key is the tag name and the value is the tag value. | `map(string)` | `{}` | no |
| <a name="input_db_cluster_parameter_group_name"></a> [db\_cluster\_parameter\_group\_name](#input\_db\_cluster\_parameter\_group\_name) | A cluster parameter group to associate with the cluster. Parameters in a DB cluster parameter group apply to every DB instance in a DB cluster. | `string` | `null` | no |
| <a name="input_db_instance_parameter_group_name"></a> [db\_instance\_parameter\_group\_name](#input\_db\_instance\_parameter\_group\_name) | An instance parameter group to associate with the cluster instances. Parameters in a DB parameter group apply to a single DB instance in an Aurora DB cluster. | `string` | `null` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | The name for your database of up to 8 alpha-numeric characters. If you do not provide a name, Amazon RDS will not create a database in the DB cluster you are creating. | `string` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true. | `bool` | `null` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | If non-empty, the Aurora cluster will export the specified logs to Cloudwatch. Must be zero or more of: audit, error, general and slowquery | `list(string)` | `[]` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | The name of the database engine to be used for the RDS instance. Must be aurora-postgresql. | `string` | `"aurora-postgresql"` | no |
| <a name="input_engine_mode"></a> [engine\_mode](#input\_engine\_mode) | The version of aurora to run - provisioned or serverless. | `string` | `"provisioned"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The version of the engine in var.engine to use. | `string` | `null` | no |
| <a name="input_global_cluster_identifier"></a> [global\_cluster\_identifier](#input\_global\_cluster\_identifier) | Global cluster identifier when creating the global secondary cluster. | `string` | `null` | no |
| <a name="input_hal_app_id"></a> [hal\_app\_id](#input\_hal\_app\_id) | ID of the Hal application | `string` | `null` | no |
| <a name="input_iam_database_authentication_enabled"></a> [iam\_database\_authentication\_enabled](#input\_iam\_database\_authentication\_enabled) | Specifies whether mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled. Disabled by default. | `bool` | `false` | no |
| <a name="input_iam_roles"></a> [iam\_roles](#input\_iam\_roles) | A List of ARNs for the IAM roles to associate to the RDS Cluster. | `list(string)` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The instance type to use for the db (For production, we recommend to use db.r5.x). | `string` | `"db.t3.medium"` | no |
| <a name="input_is_primary"></a> [is\_primary](#input\_is\_primary) | Determines whether or not to create an RDS global cluster. If true, then it creates the global cluster with a primary else it only creates a secondary cluster. | `bool` | `false` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The ARN of a KMS key that should be used to encrypt data on disk. Only used if var.storage\_encrypted is true. If you leave this null, the default RDS KMS key for the account will be used. | `string` | `null` | no |
| <a name="input_module_source"></a> [module\_source](#input\_module\_source) | The source of the terraform module.  Automatically populated by HAL. | `string` | `""` | no |
| <a name="input_module_version"></a> [module\_version](#input\_module\_version) | The version of the terraform module.  Automatically populated by HAL. | `string` | `""` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0.  Allowed values: 0, 1, 5, 15, 30, 60 | `number` | `0` | no |
| <a name="input_monitoring_role_arn"></a> [monitoring\_role\_arn](#input\_monitoring\_role\_arn) | The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Be sure this role exists. It will not be created here. You must specify a MonitoringInterval value other than 0 when you specify a MonitoringRoleARN value that is not empty string. | `string` | `null` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Specifies whether Performance Insights is enabled or not. | `bool` | `false` | no |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input\_performance\_insights\_kms\_key\_id) | The ARN for the KMS key to encrypt Performance Insights data. | `string` | `null` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | Amount of time in days to retain Performance Insights data. Valid values are 7, 731 (2 years) or a multiple of 31.Default to 7 day as it is free. | `number` | `7` | no |
| <a name="input_port"></a> [port](#input\_port) | The port the DB will listen on. | `number` | `5432` | no |
| <a name="input_preferred_backup_window"></a> [preferred\_backup\_window](#input\_preferred\_backup\_window) | The daily time range during which automated backups are created (e.g. 04:00-09:00). Time zone is UTC. Performance may be degraded while a backup runs. | `string` | `"06:00-07:00"` | no |
| <a name="input_preferred_maintenance_window"></a> [preferred\_maintenance\_window](#input\_preferred\_maintenance\_window) | The weekly day and time range during which system maintenance can occur (e.g. wed:04:00-wed:04:30). Time zone is UTC. Performance may be degraded or there may even be a downtime during maintenance windows. | `string` | `"sun:07:00-sun:08:00"` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | The default is false, which means the database is only accessible from within the VPC, which is much more secure. If you wish to make your database accessible from the public Internet, set this flag to true (WARNING: NOT RECOMMENDED FOR PRODUCTION USAGE!!). | `bool` | `false` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | Define the retention period of postgresql log. | `number` | `7` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Determines whether a final DB snapshot is created before the DB instance is deleted. Be very careful setting this to true; if you do, and you delete this DB instance, you will not have any backups of the data! | `bool` | `false` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | This is the field need to be configured when we do a cluster rebuild for iac upgrade. This is the Snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05. | `string` | `null` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Specifies whether the DB cluster uses encryption for data at rest in the underlying storage for the DB, its automated backups, Read Replicas, and snapshots. Uses the default aws/rds key in KMS. | `bool` | `true` | no |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | Amazon Resource Name (ARN) of cluster |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | The DNS address of the RDS instance |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | The RDS Cluster Identifier |
| <a name="output_cluster_resource_id"></a> [cluster\_resource\_id](#output\_cluster\_resource\_id) | The RDS Cluster Resource ID |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | The database name. |
| <a name="output_dbi_resource_id"></a> [dbi\_resource\_id](#output\_dbi\_resource\_id) | The region-unique, immutable identifier for the DB instance. |
| <a name="output_instance_endpoints"></a> [instance\_endpoints](#output\_instance\_endpoints) | The DNS address for this instance. |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | The Instance identifie.r |
| <a name="output_port"></a> [port](#output\_port) | The database port number. |
| <a name="output_reader_endpoint"></a> [reader\_endpoint](#output\_reader\_endpoint) | A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Id of the specific security group to retrieve. |

<!-- END_TF_DOCS -->