# Change Log
All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/).

<!-- ## [Unreleased]

Sections: (`Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`) -->
## [0.0.1] - 2023-03-17
**This is the first version of aws-aurora-postgresql-tf module (dedicated for rds aurora with postgresql) which was based of the original aws-aurora-tf module. Compare to the shared module it has enhancements listed below and will use tf 1.x and provider 4.x.**

### Changed
> :warning: **POTENTIALLY BREAKING CHANGE:**
- Took out storage_encrypted variable from couple places and the example files due to the storage encryption is required and has validation as true in the variables.tf.
- Took out the variable performance_insights_kms_key_id which will use the same kms key as storage encryption for Performance Insights.
- Changed variable parameter_family_name as required field and has default value as "aurora-postgresql13" which is the most current released LTS version to force to create custom parameter group for cluster and instance instead of AWS default parameter group. Also set up parameter_family_name as 'aurora-postgresql11' which is LTS version for Serverless. 
- Took out 'publicly_accessible' variable which has validation value as 'false' because we only allow the database to be accessible from within the VPC, which is much more secure. 
- Changed the default value for variable custom_subnet_name_filter to "*-private-az*" and allow custom value including private persistant subnets in case teams have not been upgraded to VPC 3.0 which change private persistant to private.
- Update tags.tf to version 3.1.0 to be compatible with Terraform 1.0 version and aws Provider 4.0.
- Other changes to define local variable instead of repeated code in couple modules.
- Remove server_side_encryption_configuration parameter from aws_s3_bucket resource due to deprecation and use aws_s3_bucket_server_side_encryption_configuration resource instead.
- Remove local-exec code blocks that used to handle propogation dependencies on iam role, policy attachment and RDS role association. Instead, using hasicorp/time provider time_sleep resource to handle propogation dependency.
- Changed the default value in submodules for ca_cert_identifier from "rds-ca-2019" to "rds-ca-rsa2048-g1" in order to switch to a new standard CA that support auto cert rotation by RDS.
- For Aurora Global Database, Primary and Secondary instances now have region specific names to prevent issues with same name resources in the AWS UI.
- Primary and Secondary IAM roles now have region specific names to allow S3 import and export to work on both regions after failover.

### Added

- variables.tf: 
    - Validate `instance_type` variable to not allow r4 instance types which will be obsoleted by AWS in the near future. If you encountered this validation error on the destroy, just change your `instance_type` on your old terraform.tfvars to any other instance types except of r4, then re-run the destroy to by-pass this validation error.
    - engine: Validate the value as aurora-postgresql. 
    - pilotlight_enabled: The default is false but we recommend to set it to true because it has lowest cost, so we want teams to have headless secondary cluster as default. If you want to change an existed global database which originally has reader instances in the secondary cluster to have zero instance, you can either manually delete the reader instance from the secondary cluster from AWS Console or run AWS CLI or re-deploy the secondary cluster with the pilotlight_enabled = true in the secondary cluster terraform.tfvars which will be an in-placed deployment. :warning: It will not allow to delete the instances if the deletion_protection setup as true, you have to manually disable the deletion_protection first before deleting the instances.
    - burstable_tag: Add memory tag according to the instance type for provisioned clusters to so we can build different threshold and performance monitoring in Dynatrace to differentiate burstable instance type and memory enhanced instance type.
    - auto_minor_version_upgrade: Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. AWS default is true, but we provide an option to let team to choose enabling or not. If team uses LTS release path and want to avoid multiple upgrade cycle, they should leave it as default value false to disable the auto minor version upgrade. But if team wants to use rapid release path and is willing to go through more minor version release, they need to change this value to true to enable the auto minor version upgrade. This is only applied to Provisioned and Global Instances.
    - create_initial_global_cluster: When deploying for the first time set this to true. On subsequent pushes, set to false. This will prevent the plan and apply from recreating the global cluster every time.
    - Add "ca_cert_identifier" to allow user to define the RDS CA cert used for instances.
    - Add "retention_in_days" to allow user to define the retention period for explicitly created cloudwatch log group.
    - Add "performance_insights_retention_period" to allow user to define the retention period for performance insight.
- variables.standard.tf: Moved some standard variables out of variable.tf to this file.
- Use aws_subnets data source instead of "aws_subnet_ids" data source which has been deprecated and will be removed in a future version.
- Add IAM DB Auth for Global Secondary Cluster.
- Add missing required tags.
- Modulized cluster and instance parameter groups. 
- Add pre-loaded libraries: pg_stat_statements and pg_cron into default cluster parameters.
- add ca_cert_identifier to main.tf to allow user configure and change CA cert.
- explicitly create aws_cloudwatch_log_group resource to ensure the log group has proper retention and tagging to better align enterprise policy.
  
### Removed

- remove unused variable "ca_cert_identifier" from serverless submodule
- remove unnecessary burst_tags tag on aurora global submodule input since burstable instance is not supported with Aurora Global database
- remove "performance_insights_kms_key_id" from main module variable as it is being setted as the same as the cluster CMK when a CMK is provided for prod or beta environment. 