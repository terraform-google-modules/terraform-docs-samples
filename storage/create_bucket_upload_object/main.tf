# Create new storage bucket in the US multi-region
# with standard storage

# [START storage_create_bucket_upload_object_tf]
resource "google_storage_bucket" "static" {
  project       = "<var>PROJECT_ID</var>"
  name         = "<var>BUCKET_NAME</var>"
  location      = "US"
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
}

# Upload a text file as an object
# to the storage bucket

resource "google_storage_bucket_object" "default" {
  name = "<var>OBJECT_NAME</var>"
  source       = "<var>OBJECT_PATH</var>"
  content_type = "text/plain"
  bucket       = google_storage_bucket.static.id
}
# [END storage_create_bucket_upload_object_tf]
