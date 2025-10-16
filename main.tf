
module "data_pipeline" {
  source = "./modules/data-pipeline"

  project_name         = var.project_name
  aws_region_secondary = var.aws_region_secondary
}


module "frontend_hosting" {
  source = "./modules/frontend-hosting"

  project_name       = var.project_name
  aws_region_primary = var.aws_region_primary
}


module "api_backend" {
  source = "./modules/api-backend"

  project_name            = var.project_name
  aws_region_secondary    = var.aws_region_secondary
  aws_account_id          = var.aws_account_id
  quicksight_dashboard_id = var.quicksight_dashboard_id
  quicksight_user_arn     = var.quicksight_user_arn

  upload_bucket_name      = module.data_pipeline.raw_data_bucket_name
}