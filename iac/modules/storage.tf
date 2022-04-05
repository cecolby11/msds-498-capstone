# bucket for files to be processed through the batch Dataflow ETL 
resource "google_storage_bucket" "load" {
  name                        = "raw_csv_files" # ensure globally unique
  force_destroy               = false # delete files to delete bucket
  location                    = "US"
  uniform_bucket_level_access = true

  labels = local.labels
}

# bucket for Dataflow JavaScript code containing your user-defined functions. 
# Ex: gs://my-bucket/my-transforms/*.js
resource "google_storage_bucket" "dataflow_functions" {
    name          = "dataflow_functions"
    location      = "US"
    force_destroy = true
}
