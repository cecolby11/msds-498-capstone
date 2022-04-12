# add storage.objects.create permission on the BUCKET for the cloud function, vs adding to the cloud function

resource "google_project_iam_custom_role" "producer_storage_operations" {
  role_id     = "CloudFunction_Producer_WriteData_Permissions"
  title       = "Custom Role for ETL Producer Cloud Function"
  description = "Permissions for operations executed by CF Producer node.js code"
  permissions = [
    "storage.objects.create",
  ]
}

# grant object creator permissions to service account used by cloud front for bucket
resource "google_storage_bucket_iam_member" "producer" {
  bucket = google_storage_bucket.load.name
  role   = google_project_iam_custom_role.producer_storage_operations.id
  member = "serviceAccount:${google_service_account.producer_fxn.email}"
}

# add pubsub publish permission binding to the TOPIC not the cloud function 
resource "google_pubsub_topic_iam_binding" "example_binding" {
  project = google_pubsub_topic.example.project
  topic = google_pubsub_topic.example.name
  role = "roles/pubsub.publisher"
  members = [
    "serviceAccount:${google_service_account.producer_fxn.email}",
  ]
}
