# Add this file to your module repository

module "tags" {

  source                        = "git::https://git.rockfin.com/terraform/aws-tags-tf.git?ref=3.1.0"
  module                        = local.module_name
  app_id                        = var.app_id
  hal_app_id                    = var.hal_app_id
  environment                   = var.environment
  development_team_email        = var.development_team_email
  infrastructure_team_email     = var.infrastructure_team_email
  infrastructure_engineer_email = var.infrastructure_engineer_email
  module_source                 = var.module_source
  module_version                = var.module_version
  #iac_source                    = var.iac_source

}

locals {
  iac_tags = module.tags.iac_tags
}
