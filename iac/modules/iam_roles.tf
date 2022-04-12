
resource "google_service_account" "scheduler_invoker" {
  account_id   = "scheduler-invoker-producer"
  display_name = "Cloud Scheduler Invoker Service Account"
}

resource "google_service_account" "producer_fxn" {
  account_id   = "etl-producer"
  display_name = "Cloud Function Producer Service Account"
}
