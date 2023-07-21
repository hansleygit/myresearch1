terragrunt_source = "git::https://git.rockfin.com/terraform/aws-aurora-postgresql-tf.git?ref=X.X.X"

# ----------------------------------------------------------------------------------------------------------------------
# Required variables for AWS
# ----------------------------------------------------------------------------------------------------------------------

aws_region     = "us-west-2"
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

# ----------------------------------------------------------------------------------------------------------------------
# Networking
# ----------------------------------------------------------------------------------------------------------------------

vpc_id = "vpc-000000000000"
#subnet_ids          = ["subnet-000000000000", "subnet-111111111111", ] # Uncomment this line to override automatic subnet_id data lookup

allow_connections_from_security_groups = [sg-00000000000000000] # Security groups of resources conecting to RDS should be listed

# ----------------------------------------------------------------------------------------------------------------------
# Database
# Use a command like the following to get a list of available engines and versions:
# - aws rds describe-db-engine-versions --region us-east-1 | jq -r '.DBEngineVersions[] | [.Engine, .EngineVersion] | @tsv'
# ----------------------------------------------------------------------------------------------------------------------
engine_version  = "13.9"
database_name   = "mydb"
master_username = "root" # Allowed Values ( root and administrator )
#master_password = "000" # Don't set password here. Set it up via '_TF_master_password' in HAL > Manage Application > Encrypted Configuration
parameter_family_name           = "aurora-postgresql13"
enabled_cloudwatch_logs_exports = ["postgresql"]
# ----------------------------------------------------------------------------------------------------------------------
# Global cluster
# ----------------------------------------------------------------------------------------------------------------------

is_secondary  = true        # set False for Global primary cluster and True for secondary global cluster.
source_region = "us-east-2" # Region of the Primary global cluster

# ----------------------------------------------------------------------------------------------------------------------
# Instance
# ----------------------------------------------------------------------------------------------------------------------

instance_count = 1
instance_type  = "db.r5.large" #for global databases minimum supported size is db.r5.large

# ----------------------------------------------------------------------------------------------------------------------
# Encryption
# ----------------------------------------------------------------------------------------------------------------------

#storage_encrypted = true
kms_key_arn = "kms-key-id" # kms key id for encryption of data at rest

# ----------------------------------------------------------------------------------------------------------------------
# Monitoring
# ----------------------------------------------------------------------------------------------------------------------

apply_immediately            = true
performance_insights_enabled = false
skip_final_snapshot          = false

pilotlight_enabled = false

pg_iam_features = {
  "s3Import"   = "True",
  "s3Export"   = "True",
  "Lambda"     = "False",
  "SageMaker"  = "False",
  "Comprehend" = "False",
}

# ----------------------------------------------------------------------------------------------------------------------
# IAM Auth
# ----------------------------------------------------------------------------------------------------------------------
iam_database_authentication_enabled = true
db_user_name                        = ["root", "root2"]

# ----------------------------------------------------------------------------------------------------------------------
# Migrating
# ----------------------------------------------------------------------------------------------------------------------
## If you dont have a global cluster yet, set this to true. Once the global cluster is created, turn this back to false.
create_initial_global_cluster = false
