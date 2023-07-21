terragrunt_source = "git::https://git.rockfin.com/terraform/aws-aurora-postgresql-tf.git//modules/aurora-event-subscription?ref=X.X.X" #change




aws_region       = "us-east-2"    #Region of existing RDS
aws_account_id   = "000000000000" #Account ID of the AWS Account
app_id           = "000000"       #Core-app id
application_name = "myapp"        #Application name- same as RDS
environment      = "test"         #Environment


info_emails   = ["example1@quickenloans.com", "example2@quickenloans.com"] #Informational emails from RDS event subscription
oncall_emails = ["example1@quickenloans.com", "example2@quickenloans.com"] #On-call emails for RDS on-call notifications

####################################### TAGS ##################################

development_team_email        = "example@quickenloans.com"
infrastructure_team_email     = "example@quickenloans.com"
infrastructure_engineer_email = "example@quickenloans.com"
kms_key_arn                   = "kms-key-id" # # ARN of KMS to encrypt SNS traffic
subscription_protocol         = "email"
endpoint_auto_confirms        = true
app_tags = {
  hal-app-id = "0000"
}
