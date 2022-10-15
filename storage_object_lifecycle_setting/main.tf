# [START storage_create_lifecycle_setting_tf]
resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "auto_expire" {
  provider                    = google-beta
  name                        = "${random_id.bucket_prefix.hex}-example-bucket"
  location                    = "US"
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
