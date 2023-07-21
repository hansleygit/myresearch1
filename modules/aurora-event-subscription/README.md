## Purpose

Amazon RDS uses the Amazon Simple Notification Service (Amazon SNS) to provide notification when an Amazon RDS event
occurs. Amazon RDS groups these events into categories that you can subscribe to so that you can be notified when an
event in that category occurs.
More details are available here, https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_Events.html

## This module creates the following resources

- Create two sns topics.
    - The oncall sns topic will be named as {var.environment}-{var.application\_name}-notify-oncall
    - The informational sns topic will be name as {var.environment}- {var.application\_name}-notify-info
- For each email provided in the {var.oncall\_emails} and {var.info\_emails}, there will be a sns subscription created with SMTP protocol. Recipients need to make sure confirm the subscription by click the "Confirm subscription" link from aws notification email.
- All SNS topic would need to have SSE (Server-Side Encryption) enabled and use kms\_key\_arn
## Example Project

See example `tfvars` in the [examples](../../examples) directory, and use it in a project following the
[terraform-starter-kit](https://git.rockfin.com/terraform/terraform-starter-kit) structure.

<!-- BEGIN_TF_DOCS -->


#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.0 |

#### Resources

- resource.aws_cloudwatch_metric_alarm.cpu_utilization_alarm (modules\aurora-event-subscription\main.tf#95)
- resource.aws_db_event_subscription.rds_info_event (modules\aurora-event-subscription\main.tf#61)
- resource.aws_db_event_subscription.rds_oncall_event (modules\aurora-event-subscription\main.tf#25)
- resource.aws_sns_topic.rds_notify_info (modules\aurora-event-subscription\main.tf#80)
- resource.aws_sns_topic.rds_notify_oncall (modules\aurora-event-subscription\main.tf#46)
- resource.aws_sns_topic_subscription.info_notification_topic_subscription (modules\aurora-event-subscription\main.tf#86)
- resource.aws_sns_topic_subscription.oncall_notification_topic_subscription (modules\aurora-event-subscription\main.tf#52)
- data source.aws_kms_key.sns_encryption (modules\aurora-event-subscription\main.tf#21)
- data source.aws_rds_cluster.rds-cluster (modules\aurora-event-subscription\main.tf#17)

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
| <a name="input_info_emails"></a> [info\_emails](#input\_info\_emails) | SNS subscription email | `list(string)` | n/a | yes |
| <a name="input_infrastructure_engineer_email"></a> [infrastructure\_engineer\_email](#input\_infrastructure\_engineer\_email) | The infrastructure engineer email address that is responsible for this resource(s). | `string` | n/a | yes |
| <a name="input_infrastructure_team_email"></a> [infrastructure\_team\_email](#input\_infrastructure\_team\_email) | The infrastructure team email address that is responsible for this resource(s). | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The ARN of a KMS key that should be used to encrypt AWS SNS topic for service events. | `string` | n/a | yes |
| <a name="input_oncall_emails"></a> [oncall\_emails](#input\_oncall\_emails) | SNS subscription email | `list(string)` | n/a | yes |
| <a name="input_subscription_protocol"></a> [subscription\_protocol](#input\_subscription\_protocol) | The protocol to use. The possible values for this are: sqs, sms, lambda, application, https, email | `any` | n/a | yes |
| <a name="input_app_tags"></a> [app\_tags](#input\_app\_tags) | Extra tags to apply to created resources | `map(string)` | `{}` | no |
| <a name="input_cpu_utilization_threshold"></a> [cpu\_utilization\_threshold](#input\_cpu\_utilization\_threshold) | This is the threshold value for CPU utilization for cloudwatch metric alarm. | `number` | `75` | no |
| <a name="input_endpoint_auto_confirms"></a> [endpoint\_auto\_confirms](#input\_endpoint\_auto\_confirms) | (Optional) Boolean indicating whether the end point is capable of auto confirming subscription e.g., PagerDuty (default is false) If using HTTPS, this must be set to true | `bool` | `false` | no |
| <a name="input_hal_app_id"></a> [hal\_app\_id](#input\_hal\_app\_id) | ID of the Hal application | `string` | `null` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | KMS Key used to encrypt SNS in transit | `string` | `null` | no |
| <a name="input_module_source"></a> [module\_source](#input\_module\_source) | The source of the terraform module.  Automatically populated by HAL. | `string` | `""` | no |
| <a name="input_module_version"></a> [module\_version](#input\_module\_version) | The version of the terraform module.  Automatically populated by HAL. | `string` | `""` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Add additional prefix to beginning of resource names. | `string` | `""` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Add additional suffix to end of resource names. | `string` | `""` | no |

#### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cloudwatch_alarm_name"></a> [cloudwatch\_alarm\_name](#output\_cloudwatch\_alarm\_name) | The descriptive name for the alarm. This name must be unique within the user's AWS account |
| <a name="output_info_sns_topic_arn"></a> [info\_sns\_topic\_arn](#output\_info\_sns\_topic\_arn) | The ARN of the SNS topic for information events. |
| <a name="output_info_sns_topic_name"></a> [info\_sns\_topic\_name](#output\_info\_sns\_topic\_name) | The name of the topic for information events. Topic names must be made up of only uppercase and lowercase ASCII letters, numbers, underscores, and hyphens, and must be between 1 and 256 characters long. For a FIFO (first-in-first-out) topic, the name must end with the .fifo suffix. If omitted, Terraform will assign a random, unique name. |
| <a name="output_oncall_sns_topic_arn"></a> [oncall\_sns\_topic\_arn](#output\_oncall\_sns\_topic\_arn) | The ARN of the SNS topic for oncall events. |
| <a name="output_oncall_sns_topic_name"></a> [oncall\_sns\_topic\_name](#output\_oncall\_sns\_topic\_name) | The name of the topic for oncall events. Topic names must be made up of only uppercase and lowercase ASCII letters, numbers, underscores, and hyphens, and must be between 1 and 256 characters long. For a FIFO (first-in-first-out) topic, the name must end with the .fifo suffix. If omitted, Terraform will assign a random, unique name. |

<!-- END_TF_DOCS -->