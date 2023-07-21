terragrunt_source = "git::https://git.rockfin.com/terraform/aws-aurora-postgresql-tf.git?ref=X.X.X"

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

app_tags = {
  hal-app-id = "0000"
}
# ----------------------------------------------------------------------------------------------------------------------
# Networking
# ----------------------------------------------------------------------------------------------------------------------

vpc_id = "vpc-000000000000"
#subnet_ids          = ["subnet-000000000000", "subnet-111111111111", ] #Uncomment this line to override automatic subnet_id data lookup

allow_connections_from_security_groups = [sg-00000000000000000] # Security groups of resources conecting to RDS should be listed

# ----------------------------------------------------------------------------------------------------------------------
# Database
# Use a command like the following to get a list of available engines and versions:
# - aws rds describe-db-engine-versions --region us-east-1 | jq -r '.DBEngineVersions[] | [.Engine, .EngineVersion] | @tsv'
# Note:- Latest PostgreSQL engine supported for Aurora PostgreSQL serverless v1 is 11.16 
# and serverless is only recommended in nonprod environments. 
# For production environment it is recommended to use Aurora PostgreSQL Provisioned.
# https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.relnotes.html
# ----------------------------------------------------------------------------------------------------------------------

engine_version = "11.16" # check here for updated version https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless.relnotes.html
engine_mode    = "serverless"

database_name = "mydb"

master_username = "root" # Allowed Values ( "root" and "administrator" only )
#master_password = "000" # Don't set password here. Set it up via '_TF_master_password' in HAL > Manage Application > Encrypted Configuration

parameter_family_name = "aurora-postgresql11" # make necessary change according to your engine_version

enabled_cloudwatch_logs_exports = ["postgresql"]
# ----------------------------------------------------------------------------------------------------------------------
# Serverless
# https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v1.how-it-works.html#aurora-serverless.how-it-works.auto-scaling 
#
# You can specify the minimum and maximum ACU. The minimum Aurora capacity unit is the lowest ACU to which the DB cluster can scale down. The
# maximum Aurora capacity unit is the highest ACU to which the DB cluster can scale up. Based on your settings, Aurora Serverless automatically
# creates scaling rules for thresholds for CPU utilization, connections, and available memory.
# ----------------------------------------------------------------------------------------------------------------------

scaling_min_capacity             = 2    # Valid Aurora PostgreSQL capacity values are (2, 4, 8, 16, 32, 64, 192, and 384)
scaling_max_capacity             = 16   # Valid Aurora PostgreSQL capacity values are (2, 4, 8, 16, 32, 64, 192, and 384)
scaling_auto_pause               = true # default is true which is scaling to zero
scaling_seconds_until_auto_pause = 300  # This unit is in seconds. 300 seconds = 5 minutes.Max is 24 hours.

# ----------------------------------------------------------------------------------------------------------------------
# Encryption
# The cluster volume for an Aurora Serverless v1 cluster is always encrypted. You can choose the encryption key, but you can't disable encryption.
# https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/aurora-serverless-v1.how-it-works.html#aurora-serverless.how-it-works.auto-scaling
# ----------------------------------------------------------------------------------------------------------------------
kms_key_arn = null # if it is null, it will use AWS key, but you can provide your own CMK. 

# ----------------------------------------------------------------------------------------------------------------------
# Monitoring
# ----------------------------------------------------------------------------------------------------------------------

apply_immediately = true
#performance_insights_enabled = false # Performance Insights does not apply to Serverless
skip_final_snapshot = false

preferred_backup_window      = ""
preferred_maintenance_window = ""