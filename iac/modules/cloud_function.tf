locals {
  cf_producer_zip_withhash = "producer-${data.archive_file.producer_code_zip.output_md5}.zip"
}

data "archive_file" "producer_code_zip" {
  type        = "zip"
  source_dir  = var.cf_producer_source_dir
  output_path = "${var.cf_dist_output_dir}/producer.zip"
}

resource "google_storage_bucket_object" "producer_deployment_zip" {
  name   = "${var.cf_dist_output_dir}/${local.cf_producer_zip_withhash}" # use the zip hash in the name of the bucket object, else google won't notice the code changed 
  bucket = google_storage_bucket.cf_deployment_code.name
  source = "${var.cf_dist_output_dir}/producer.zip"
}

resource "google_cloudfunctions_function" "producer_fxn" {
  name        = "${var.app_name}-producer-${var.env}"
  description = "Scheduled ETL to Ingest data from URL and Write to Bucket or Message"
  runtime     = "nodejs14" # could not change runtime via apply, had to destroy and then recreate the function 

  # configure to run as the service account terraformed instead of default
  service_account_email = google_service_account.producer_fxn.email

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.cf_deployment_code.name
  source_archive_object = google_storage_bucket_object.producer_deployment_zip.name
  trigger_http          = true
  timeout               = 60
  entry_point           = "handler"
  labels                = local.labels
  environment_variables = {
    DESTINATION_STORAGE_BUCKET_NAME = google_storage_bucket.load.name
    DESTINATION_PUBSUB_TOPIC_NAME = google_pubsub_topic.example.name
  }
}
