resource "google_bigquery_dataset" "warehouse" {
  dataset_id    = "msds_498_warehouse"
  friendly_name = "msds_498_warehouse"
  description   = "Warehouse for ETL project"
  location      = "US"

  labels = local.labels
}

resource "google_bigquery_table" "tweets" {
  dataset_id = google_bigquery_dataset.warehouse.dataset_id
  table_id   = "tweets_${var.env}"

  labels = local.labels
  # NOTE: : On newer versions of the provider, you must explicitly set deletion_protection=false (and run terraform apply to write the field to state) in order to destroy an instance. 
  # It is recommended to not set this field (or set it to true) until you're ready to destroy.
  deletion_protection = false // # @TODO: flip this to true once I have the infra how I want it 

  schema = file("${path.module}/twitter-bq-schema.json")
}

resource "google_bigquery_table" "insurance" {
  dataset_id = google_bigquery_dataset.warehouse.dataset_id
  table_id   = "insurance_${var.env}"

  labels = local.labels
  # NOTE: : On newer versions of the provider, you must explicitly set deletion_protection=false (and run terraform apply to write the field to state) in order to destroy an instance. 
  # It is recommended to not set this field (or set it to true) until you're ready to destroy.
  deletion_protection = false // # @TODO: flip this to true once I have the infra how I want it 

  schema = file("${path.module}/insurance-bq-schema.json")
}
