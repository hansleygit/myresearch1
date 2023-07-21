# ----------------------------------------------------------------------------------------------------------------------
# Required variables for AWS
# ----------------------------------------------------------------------------------------------------------------------

aws_region     = "us-west-2"
aws_account_id = "808835449166"

# ----------------------------------------------------------------------------------------------------------------------
# Standard Module Required Variables
# ----------------------------------------------------------------------------------------------------------------------

development_team_email        = "team@quickenloans.com"
infrastructure_team_email     = "team@quickenloans.com"
infrastructure_engineer_email = "user@quickenloans.com"

environment = "test"
#app_id           = "123456"
application_name = "auroratf"

app_tags = {
  hal-app-id = "00000"
}

# ----------------------------------------------------------------------------------------------------------------------
# Networking
# ----------------------------------------------------------------------------------------------------------------------

vpc_id = "vpc-0724e0bd0f3ef3b77"

#publicly_accessible = false # Set to true to allow public access outside the VPC. (WARNING: NOT RECOMMENDED OUTSIDE OF SANDBOX!!)

allow_connections_from_cidr_blocks = [
  "12.165.188.0/24",
  "162.252.136.0/21"
]

allow_connections_from_security_groups = []

# ----------------------------------------------------------------------------------------------------------------------
# Database
# Use a command like the following to get a list of available engines and versions:
# - aws rds describe-db-engine-versions --region us-east-1 | jq -r '.DBEngineVersions[] | [.Engine, .EngineVersion] | @tsv'
# ----------------------------------------------------------------------------------------------------------------------
# aurora postgresql serverless https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.relnotes.html
# support version can be 11-compatible version now

engine_version        = "11.16"
engine_mode           = "serverless"
parameter_family_name = "aurora-postgresql11"

database_name = "terratestdb"

master_username = "root"
master_password = "terratestpassword" # TIP: Set via '_TF_master_password' in HAL > Manage Application > Encrypted Configuration

enabled_cloudwatch_logs_exports = ["postgresql"]

scaling_min_capacity             = 2 # Valid capacity values are 2, 4, 8, 16, 32, 64, 128, and 256
scaling_max_capacity             = 4 # Valid capacity values are 2, 4, 8, 16, 32, 64, 128, and 256
scaling_auto_pause               = true
scaling_seconds_until_auto_pause = 300

kms_key_arn = "arn:aws:kms:us-west-2:808835449166:alias/test-000000-terratest"
#performance_insights_kms_key_id = "arn:aws:kms:us-west-2:808835449166:alias/test-000000-terratest"

# ----------------------------------------------------------------------------------------------------------------------
# Monitoring
# ----------------------------------------------------------------------------------------------------------------------

apply_immediately = true
#performance_insights_enabled = false # not applied for Serverless
skip_final_snapshot = true

preferred_backup_window      = ""
preferred_maintenance_window = ""