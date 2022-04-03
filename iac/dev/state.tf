terraform {
  backend "gcs" {
    bucket      = "tfstate_498_dev"
    prefix      = "project"
  }
}
