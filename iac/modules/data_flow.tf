# resource "google_dataflow_job" "batch_etl" {
#   name              = "dataflow-job"
#   # e.g. "gs://my-bucket/templates/template_file"
#   template_gcs_path = "${google_storage_bucket.dataflow_functions.url}/templates/batch_etl"
#   # e.g. "gs://my-bucket/tmp_dir"
#   temp_gcs_location = "${google_storage_bucket.dataflow_functions.url}/tmp_dir"
  
#   parameters = {
#     foo = "bar"
#     baz = "qux"
#   }
# }
