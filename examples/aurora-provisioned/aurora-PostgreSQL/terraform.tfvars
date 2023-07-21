terragrunt_source = "git::https://git.rockfin.com/terraform/aws-aurora-postgresql-tf.git?ref=X.X.X"

# ----------------------------------------------------------------------------------------------------------------------
# Required variables for AWS
# ----------------------------------------------------------------------------------------------------------------------

aws_region     = "us-east-2"
aws_account_id = "000000000000" #Account ID of the AWS Account

# ----------------------------------------------------------------------------------------------------------------------
# Standard Module Required Variables
# ----------------------------------------------------------------------------------------------------------------------

development_team_email        = "example@rocketmortgage.com"
infrastructure_team_email     = "example@rocketmortgage.com"
infrastructure_engineer_email = "example@rocketmortgage.com"

app_id           = "000000"
application_name = "myapp"
environment      = "test"

app_tags = {
  hal-app-id = "0000"
}

# ----------------------------------------------------------------------------------------------------------------------
# Networking
# ----------------------------------------------------------------------------------------------------------------------

vpc_id = "vpc-000000000000" # Your VPC ID

#subnet_ids          = ["subnet-000000000000", "subnet-111111111111", ] # Uncomment this line to override automatic subnet_id data lookup

allow_connections_from_security_groups = ["sg-00000000000000000"] # Security groups of resources conecting to RDS should be listed

# ----------------------------------------------------------------------------------------------------------------------
# Database
# Use a command like the following to get a list of available engines and versions:
# - aws rds describe-db-engine-versions --region us-east-1 | jq -r '.DBEngineVersions[] | [.Engine, .EngineVersion] | @tsv'
# ----------------------------------------------------------------------------------------------------------------------

engine_version = "13.9" # We recommend using LTS version, check here for updated version https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraPostgreSQL.Updates.LTS.html
engine_mode    = "provisioned"

database_name = "myname"

master_username = "root" # # Allowed master usernames are 'root' or 'administrator' because PostgreSQL does not allow 'admin' as master username. 
#master_password = "000" # Don't set password here. Set it up via '_TF_master_password' in HAL > Manage Application > Encrypted Configuration
parameter_family_name = "aurora-postgresql13" # make necessary change according to your engine_version

enabled_cloudwatch_logs_exports = ["postgresql"]
# ----------------------------------------------------------------------------------------------------------------------
# Instance
# ----------------------------------------------------------------------------------------------------------------------

instance_count = 1              # the number of instance
instance_type  = "db.t3.medium" # t3 instance type is recommended for non-prod. r5 is recommended for production

# ----------------------------------------------------------------------------------------------------------------------
# Monitoring
# ----------------------------------------------------------------------------------------------------------------------

apply_immediately            = true
performance_insights_enabled = false # We recommend to enable it for production. see supported instance class https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/USER_PerfInsights.Overview.Engines.html
skip_final_snapshot          = false

# This only can be enabled on Aurora Provisioned and Global clusters. 
#iam_database_authentication_enabled = true # must as 'true' if you want to use IAM DB Authentiction and with below db_user_name setup
#db_user_name = ["root"] #  master username or any other database user you want it to use token to access to your database

# ----------------------------------------------------------------------------------------------------------------------
# Encryption
# ----------------------------------------------------------------------------------------------------------------------
kms_key_arn = "kms-key-id" # KMS key to encrypt your database and Performance Insights
# ----------------------------------------------------------------------------------------------------------------------
# Optional configuration
# ----------------------------------------------------------------------------------------------------------------------
preferred_backup_window      = "06:00-07:00"         # Daily backup Window. Time in UTC. You can customize it.
preferred_maintenance_window = "sun:07:00-sun:08:00" # Weekly maintenance window. Time in UTC. You can customize it.
backup_retention_period      = 2                     # If you do not provide it, it will be automatically setup 14 days for non-prod and 30 days for producation.

# enable S3Import or S3Export or Lambda Features
# We keep 'SageMaker' and 'Comprehend' as False now
# 'SageMaker' and 'Comprehend' will be developed if we have demand usages in the future.
pg_iam_features = {

  "s3Import"   = "True",  #enable S3Import
  "s3Export"   = "True",  #enable S3Export
  "Lambda"     = "False", #invoke Lambda Function
  "SageMaker"  = "False",
  "Comprehend" = "False",
}
# lambda_arn    = ["arn:aws:lambda:us-east-2:000000:function:lambdafunctioname"]  #only needed when Lambda=True in above pg_iam_features 
