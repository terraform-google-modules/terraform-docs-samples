# [START storage_create_lifecycle_setting_tf]
resource "google_storage_bucket" "auto_expire" {
  name          = "example-bucket"
  location      = "US"
  uniform_bucket_level_access = true

  lifecycle_rule {
    condition {
      age = 3
    }
    action {
      type = "Delete"
    }
  }
}
# [END storage_create_lifecycle_setting_tf]
