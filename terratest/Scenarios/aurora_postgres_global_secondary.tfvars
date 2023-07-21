# ----------------------------------------------------------------------------------------------------------------------
# Required variables for AWS
# ----------------------------------------------------------------------------------------------------------------------
aws_region     = "us-east-2"
aws_account_id = "808835449166"

# ----------------------------------------------------------------------------------------------------------------------
# Standard Module Required Variables
# ----------------------------------------------------------------------------------------------------------------------
development_team_email        = "team@quickenloans.com"
infrastructure_team_email     = "team@quickenloans.com"
infrastructure_engineer_email = "user@quickenloans.com"
environment                   = "test"
application_name              = "auroraglobaltf"
app_tags                      = { hal-app-id = "00000" }
#app_id           = "123456"

# ----------------------------------------------------------------------------------------------------------------------
# Networking
# ----------------------------------------------------------------------------------------------------------------------
vpc_id                                 = "vpc-013e6988e834cd3b1"
allow_connections_from_cidr_blocks     = ["12.165.188.0/24", "162.252.136.0/21"]
allow_connections_from_security_groups = []

# ----------------------------------------------------------------------------------------------------------------------
# Database
# Use a command like the following to get a list of available engines and versions:
# - aws rds describe-db-engine-versions --region us-east-1 | jq -r '.DBEngineVersions[] | [.Engine, .EngineVersion] | @tsv'
# ----------------------------------------------------------------------------------------------------------------------
engine_version        = "13.9"
engine_mode           = "provisioned"
parameter_family_name = "aurora-postgresql13"
database_name         = "terratestdb"
master_username       = "root"              #"terratestuser"
master_password       = "terratestpassword" # TIP: Set via '_TF_master_password' in HAL > Manage Application > Encrypted Configuration
kms_key_arn           = "arn:aws:kms:us-east-2:808835449166:alias/test-000000-terratest"
#performance_insights_kms_key_id = "arn:aws:kms:us-west-2:808835449166:alias/test-000000-terratest"

# ----------------------------------------------------------------------------------------------------------------------
# Instance
# ----------------------------------------------------------------------------------------------------------------------
instance_count = 1
instance_type  = "db.r5.large" #for global databases minimum supported size is db.r5.large

# ----------------------------------------------------------------------------------------------------------------------
# Monitoring
# ----------------------------------------------------------------------------------------------------------------------
apply_immediately               = true
performance_insights_enabled    = true
skip_final_snapshot             = true
enabled_cloudwatch_logs_exports = ["postgresql"]

# ----------------------------------------------------------------------------------------------------------------------
# IAM
# ----------------------------------------------------------------------------------------------------------------------
iam_database_authentication_enabled = true
db_user_name                        = ["root", "root2"]

# ----------------------------------------------------------------------------------------------------------------------
# S3 and other features
# ----------------------------------------------------------------------------------------------------------------------
pg_iam_features = {

  "s3Import"   = "True",
  "s3Export"   = "True",
  "Lambda"     = "False",
  "SageMaker"  = "False",
  "Comprehend" = "False"
}

# ----------------------------------------------------------------------------------------------------------------------
# Global cluster
# ----------------------------------------------------------------------------------------------------------------------
is_primary                    = false
is_secondary                  = true
create_initial_global_cluster = true
pilotlight_enabled            = false
source_region                 = "us-west-2"
global_cluster_identifier     = "global-auroraglobaltf-test-cluster"
