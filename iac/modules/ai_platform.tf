resource "google_ml_engine_model" "default" {
  name        = "simple_insurance"
  description = "Simple Insurance Model imported from BQ ML"
  regions     = [var.project_region]

  labels = local.labels

  online_prediction_logging         = false
  online_prediction_console_logging = false
}
