# Globals
variable "project_id" {}
variable  "project_region" {
    default = "us-central1"
}
variable "project_zone" {
    default = "us-central1-a"
}
variable "app_name" {}
variable "env" {}

# Cloud Function 
variable "cf_producer_source_dir" {}
variable "cf_dist_output_dir" {}
variable "cf_producer_invoke_schedule" {}
