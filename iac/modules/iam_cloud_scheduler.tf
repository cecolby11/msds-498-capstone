# scheduler needs cloudfunctions.invoker on the cloudfunctions to invoke it 
resource "google_cloudfunctions_function_iam_member" "producer_invoker" {
  project        = google_cloudfunctions_function.producer_fxn.project
  region         = google_cloudfunctions_function.producer_fxn.region
  cloud_function = google_cloudfunctions_function.producer_fxn.name

  role   = "roles/cloudfunctions.invoker"
  member = "serviceAccount:${google_service_account.scheduler_invoker.email}"
}
