resource "google_pubsub_topic" "example" {
  name = "example-topic"

  labels = local.labels

  message_retention_duration = "600s" # 10 minutes
}

# resource "google_pubsub_subscription" "example" {
#   name  = "example-subscription"
#   topic = google_pubsub_topic.example.name

#   ack_deadline_seconds = 30

#   labels = local.labels
# }
