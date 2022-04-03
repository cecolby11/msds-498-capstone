resource "google_storage_bucket" "load" {
  name                        = "${var.app_name}_${var.env}" # ensure globally unique
  force_destroy               = false # delete files to delete bucket
  location                    = "US"
  uniform_bucket_level_access = true

  labels = local.labels
}
