# cloud scheduler uses app engine cron jobs to run 
resource "google_cloud_scheduler_job" "producer_http_invoke" {
  name      = "${var.app_name}-invoke-producer-http"
  schedule  = var.cf_producer_invoke_schedule
  time_zone = "America/Chicago"

  http_target {
    uri         = google_cloudfunctions_function.producer_fxn.https_trigger_url
    http_method = "POST"
    body        = base64encode("{\"message\":\"scheduled invocation\"}")
    oidc_token {
      service_account_email = google_service_account.scheduler_invoker.email # needs cloud function invoke permissions on the function 
    }
  }

  retry_config {
    retry_count = 1
  }
}
