module "dev" {
  # globals
  source               = "../modules"
  project_id           = "dev-346101"
  app_name             = "msds498_etl"
  env                  = "dev"

  cf_producer_source_dir   = "../../src_producer_fxn"  # App code source directory for cloud function
  cf_dist_output_dir   = "../dist" # Build output dir for the cloud function .zip file
  cf_producer_invoke_schedule = "0 15 * * *"  # daily at 3pm
}
