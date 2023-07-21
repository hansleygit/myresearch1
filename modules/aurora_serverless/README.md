### Aurora Serverless module

Amazon Aurora Serverless is an on-demand, auto-scaling configuration for Amazon Aurora. It automatically starts up, shuts down, and scales capacity up or down based on your application's needs. It enables you to run your database in the cloud without managing any database capacity.

## Serverless Auto Scaling

More details about how auto-scaling works  [here](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.how-it-works.html#aurora-serverless.how-it-works.auto-scaling)

You can specify the minimum and maximum ACU. The minimum Aurora capacity unit is the lowest ACU to which the DB cluster can scale down. The
maximum Aurora capacity unit is the highest ACU to which the DB cluster can scale up. Based on your settings, Aurora Serverless automatically
creates scaling rules for thresholds for CPU utilization, connections, and available memory.

More details about their features can be found [here](https://aws.amazon.com/rds/aurora/serverless/).

## Example Project

See example `tfvars` in the [examples](../../examples/aurora-serverless) folder, and use it in a project following the
[terraform-starter-kit](https://git.rockfin.com/terraform/terraform-starter-kit) structure.

<!-- BEGIN_TF_DOCS -->


#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

#### Resources

- resource.aws_db_subnet_group.cluster (modules\aurora_serverless\main.tf#25)
- resource.aws_rds_cluster.aurora_serverless (modules\aurora_serverless\main.tf#69)
- resource.aws_security_group.cluster (modules\aurora_serverless\main.tf#37)
- resource.aws_security_group_rule.allow_connections_from_cidr_blocks (modules\aurora_serverless\main.tf#44)
- resource.aws_security_group_rule.allow_connections_from_security_group (modules\aurora_serverless\main.tf#55)
- data source.aws_caller_identity.current (modules\aurora_serverless\main.tf#20)
- data source.aws_region.current (modules\aurora_serverless\main.tf#17)

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
| <a name="input_master_password"></a> [master\_password](#input\_master\_password) | The password for the master user. If var.snapshot\_identifier is non-empty, this value is ignored. | `string` | n/a | yes |
| <a name="input_master_username"></a> [master\_username](#input\_master\_username) | The username for the master user. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name used to namespace all resources created by these templates, including the cluster and cluster instances (e.g. drupaldb). Must be unique in this region. Must be a lowercase string. | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | A list of subnet ids where the database instances should be deployed. In the standard Gruntwork VPC setup, these should be the private persistence subnet ids. | `list(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The id of the VPC in which this DB should be deployed. | `string` | n/a | yes |
| <a name="input_allow_connections_from_security_groups"></a> [allow\_connections\_from\_security\_groups](#input\_allow\_connections\_from\_security\_groups) | Specifies a list of Security Groups to allow connections from. | `list(string)` | `[]` | no |
| <a name="input_app_tags"></a> [app\_tags](#input\_app\_tags) | Extra tags to apply to created resources | `map(string)` | `{}` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Specifies whether any cluster modifications are applied immediately, or during the next maintenance window. Note that cluster modifications may cause degraded performance or downtime. | `bool` | `false` | no |
| <a name="input_aws_db_security_group_description"></a> [aws\_db\_security\_group\_description](#input\_aws\_db\_security\_group\_description) | The description of the aws\_db\_security\_group that is created. Defaults to 'Security group for the var.name DB' if not specified. | `string` | `null` | no |
| <a name="input_aws_db_security_group_name"></a> [aws\_db\_security\_group\_name](#input\_aws\_db\_security\_group\_name) | The name of the aws\_db\_security\_group that is created. Defaults to var.name if not specified. | `string` | `null` | no |
| <a name="input_aws_db_subnet_group_description"></a> [aws\_db\_subnet\_group\_description](#input\_aws\_db\_subnet\_group\_description) | The description of the aws\_db\_subnet\_group that is created. Defaults to 'Subnet group for the var.name DB' if not specified. | `string` | `null` | no |
| <a name="input_aws_db_subnet_group_name"></a> [aws\_db\_subnet\_group\_name](#input\_aws\_db\_subnet\_group\_name) | The name of the aws\_db\_subnet\_group that is created. Defaults to var.name if not specified. | `string` | `null` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | How many days to keep backup snapshots around before cleaning them up | `number` | `null` | no |
| <a name="input_custom_tags"></a> [custom\_tags](#input\_custom\_tags) | A map of custom tags to apply to the Aurora RDS Instance and the Security Group created for it. The key is the tag name and the value is the tag value. | `map(string)` | `{}` | no |
| <a name="input_db_cluster_parameter_group_name"></a> [db\_cluster\_parameter\_group\_name](#input\_db\_cluster\_parameter\_group\_name) | A cluster parameter group to associate with the cluster. Parameters in a DB cluster parameter group apply to every DB instance in a DB cluster. | `string` | `null` | no |
| <a name="input_db_instance_parameter_group_name"></a> [db\_instance\_parameter\_group\_name](#input\_db\_instance\_parameter\_group\_name) | An instance parameter group to associate with the cluster instances. Parameters in a DB parameter group apply to a single DB instance in an Aurora DB cluster. | `string` | `null` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | The name for your database of up to 8 alpha-numeric characters. If you do not provide a name, Amazon RDS will not create a database in the DB cluster you are creating. | `string` | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | If the DB instance should have deletion protection enabled. The database can't be deleted when this value is set to true. | `bool` | `null` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | If non-empty, the Aurora cluster will export the specified logs to Cloudwatch. Must be zero or more of: audit, error, general and slowquery | `list(string)` | `[]` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | The name of the database engine to be used for the RDS instance. Must be aurora-postgresql. | `string` | `"aurora-postgresql"` | no |
| <a name="input_engine_mode"></a> [engine\_mode](#input\_engine\_mode) | The version of aurora to run - provisioned or serverless. | `string` | `"serverless"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The version of the engine in var.engine to use. | `string` | `null` | no |
| <a name="input_hal_app_id"></a> [hal\_app\_id](#input\_hal\_app\_id) | ID of the Hal application | `string` | `null` | no |
| <a name="input_iam_database_authentication_enabled"></a> [iam\_database\_authentication\_enabled](#input\_iam\_database\_authentication\_enabled) | Specifies whether mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled. Disabled by default. | `bool` | `false` | no |
| <a name="input_iam_roles"></a> [iam\_roles](#input\_iam\_roles) | A List of ARNs for the IAM roles to associate to the RDS Cluster. | `list(string)` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The ARN of a KMS key that should be used to encrypt data on disk. Only used if var.storage\_encrypted is true. If you leave this null, the default RDS KMS key for the account will be used. | `string` | `null` | no |
| <a name="input_module_source"></a> [module\_source](#input\_module\_source) | The source of the terraform module.  Automatically populated by HAL. | `string` | `""` | no |
| <a name="input_module_version"></a> [module\_version](#input\_module\_version) | The version of the terraform module.  Automatically populated by HAL. | `string` | `""` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0.  Allowed values: 0, 1, 5, 15, 30, 60 | `number` | `0` | no |
| <a name="input_monitoring_role_arn"></a> [monitoring\_role\_arn](#input\_monitoring\_role\_arn) | The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. Be sure this role exists. It will not be created here. You must specify a MonitoringInterval value other than 0 when you specify a MonitoringRoleARN value that is not empty string. | `string` | `null` | no |
| <a name="input_performance_insights_enabled"></a> [performance\_insights\_enabled](#input\_performance\_insights\_enabled) | Specifies whether Performance Insights is enabled or not. | `bool` | `false` | no |
| <a name="input_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#input\_performance\_insights\_kms\_key\_id) | The ARN for the KMS key to encrypt Performance Insights data, . | `string` | `null` | no |
| <a name="input_port"></a> [port](#input\_port) | The port the DB will listen on. | `number` | `5432` | no |
| <a name="input_preferred_backup_window"></a> [preferred\_backup\_window](#input\_preferred\_backup\_window) | The daily time range during which automated backups are created (e.g. 04:00-09:00). Time zone is UTC. Performance may be degraded while a backup runs. | `string` | `"06:00-07:00"` | no |
| <a name="input_preferred_maintenance_window"></a> [preferred\_maintenance\_window](#input\_preferred\_maintenance\_window) | The weekly day and time range during which system maintenance can occur (e.g. wed:04:00-wed:04:30). Time zone is UTC. Performance may be degraded or there may even be a downtime during maintenance windows. | `string` | `"sun:07:00-sun:08:00"` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | If you wish to make your database accessible from the public Internet, set this flag to true (WARNING: NOT RECOMMENDED FOR PRODUCTION USAGE!!). The default is false, which means the database is only accessible from within the VPC, which is much more secure. | `bool` | `false` | no |
| <a name="input_scaling_configuration_auto_pause"></a> [scaling\_configuration\_auto\_pause](#input\_scaling\_configuration\_auto\_pause) | Whether to enable automatic pause. A DB cluster can be paused only when it's idle (it has no connections). If a DB cluster is paused for more than seven days, the DB cluster might be backed up with a snapshot. In this case, the DB cluster is restored when there is a request to connect to it. | `bool` | `true` | no |
| <a name="input_scaling_configuration_max_capacity"></a> [scaling\_configuration\_max\_capacity](#input\_scaling\_configuration\_max\_capacity) | The maximum capacity. The maximum capacity must be greater than or equal to the minimum capacity. Valid Aurora PostgreSQL capacity values are 2, 4, 8, 16, 32, 64, 192, and 384. | `number` | `256` | no |
| <a name="input_scaling_configuration_min_capacity"></a> [scaling\_configuration\_min\_capacity](#input\_scaling\_configuration\_min\_capacity) | The minimum capacity. The minimum capacity must be lesser than or equal to the maximum capacity. Valid Aurora PostgreSQL capacity values are 2, 4, 8, 16, 32, 64, 192, and 384. | `number` | `2` | no |
| <a name="input_scaling_configuration_seconds_until_auto_pause"></a> [scaling\_configuration\_seconds\_until\_auto\_pause](#input\_scaling\_configuration\_seconds\_until\_auto\_pause) | The time, in seconds, before an Aurora DB cluster in serverless mode is paused. Valid values are 300 through 86400. | `number` | `300` | no |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Determines whether a final DB snapshot is created before the DB instance is deleted. Be very careful setting this to true; if you do, and you delete this DB instance, you will not have any backups of the data! | `bool` | `false` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | This is the field need to be configured when we do a cluster rebuild for iac upgrade. This is the Snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05. | `string` | `null` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Specifies whether the DB cluster uses encryption for data at rest in the underlying storage for the DB, its automated backups, Read Replicas, and snapshots. Uses the default aws/rds key in KMS. | `bool` | `true` | no |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | Amazon Resource Name (ARN) of cluster |
| <a name="output_cluster_resource_id"></a> [cluster\_resource\_id](#output\_cluster\_resource\_id) | The RDS Cluster Resource ID |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | The database name. |
| <a name="output_port"></a> [port](#output\_port) | The database port number. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Id of the specific security group to retrieve. |

<!-- END_TF_DOCS -->

>**DISCLAIMER** NOTE:- scaling\_max\_capacity and scaling\_min\_capacity values for PostgreSQL Compatible Aurora engines listed below.
Valid Aurora PostgreSQL capacity values are (2, 4, 8, 16, 32, 64, 192, and 384).

