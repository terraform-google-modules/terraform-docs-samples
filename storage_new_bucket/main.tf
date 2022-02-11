# [START storage_create_new_bucket_tf]

# Create new storage bucket in the US region
# with coldline storage
resource "google_storage_bucket" "static" {
  name          = "new-bucket"
  location      = "US"
  storage_class = "COLDLINE"

  uniform_bucket_level_access = true
}

# [END storage_create_new_bucket_tf]
