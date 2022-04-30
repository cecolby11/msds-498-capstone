# bucket for files to be processed through the batch Dataflow ETL 
resource "google_storage_bucket" "load" {
  name                        = "${var.app_name}-raw" # ensure globally unique
  force_destroy               = true # delete files to delete bucket
  location                    = "US"
  uniform_bucket_level_access = true

  labels = local.labels
}

# bucket for Dataflow JavaScript code containing your user-defined functions. 
# Ex: gs://my-bucket/my-transforms/*.js
resource "google_storage_bucket" "dataflow_functions" {
    name          = "${var.app_name}-dataflow-fxns"
    location      = "US"
    force_destroy = true
    uniform_bucket_level_access = true

    labels = local.labels
}

resource "google_storage_bucket" "cf_deployment_code" {
  name = "${var.app_name}-cloud-function-code-${var.project_id}-${var.env}" # ensure globally unique
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true

  labels = local.labels
}

resource "google_storage_bucket" "bq_model_export" {
  name = "${var.app_name}-bq-model-export-${var.project_id}-${var.env}" # ensure globally unique
  location      = "US"
  force_destroy = true
  uniform_bucket_level_access = true

  labels = local.labels
}
