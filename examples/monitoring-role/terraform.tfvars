terragrunt_source = "git::https://git.rockfin.com/terraform/aws-aurora-postgresql-tf.git//modules/monitoring-role?ref=X.X.X"

# ----------------------------------------------------------------------------------------------------------------------
# Required variables for AWS
# ----------------------------------------------------------------------------------------------------------------------

aws_region     = "us-east-2"
aws_account_id = "000000000000"

# ----------------------------------------------------------------------------------------------------------------------
# Standard Module Required Variables
# ----------------------------------------------------------------------------------------------------------------------

development_team_email        = "team@quickenloans.com"
infrastructure_team_email     = "team@quickenloans.com"
infrastructure_engineer_email = "user@quickenloans.com"

app_id           = "000000"
application_name = "myapp"
environment      = "dev"
