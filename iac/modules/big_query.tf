resource "google_bigquery_dataset" "warehouse" {
  dataset_id    = "msds_498_warehouse"
  friendly_name = "msds_498_warehouse"
  description   = "Warehouse for ETL project"
  location      = "US"

  labels = local.labels
}
