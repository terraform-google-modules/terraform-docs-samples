# [START storage_static_website_create_bucket_tf]
# Create new storage bucket in the US multi-region
# with coldline storage and settings for main_page_suffix and not_found_page
resource "random_id" "prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "static_website" {
    name          = "${random_id.prefix.hex}-static-website-bucket"
    location      = "US"
    storage_class = "COLDLINE"
    website {
        main_page_suffix = "index.html"
        not_found_page = "index.html"
    }
}
# [END storage_static_website_create_bucket_tf]

# [START storage_static_website_make_bucket_public_tf]
# Make bucket public by granting allUsers READER access
resource "google_storage_bucket_access_control" "public_rule" {
  bucket = google_storage_bucket.static_website.id
  role   = "READER"
  entity = "allUsers"
}
# [END storage_static_website_make_bucket_public_tf]

# [START storage_static_website_upload_files_tf]
# Upload a simple index.html page to the bucket
resource "google_storage_bucket_object" "indexpage" {
  name         = "index.html"
  content      = "<html><body>Hello World!</body></html>"
  content_type = "text/html"
  bucket       = google_storage_bucket.static_website.id
}

# Upload a simple 404 / error page to the bucket
resource "google_storage_bucket_object" "errorpage" {
  name         = "404.html"
  content      = "<html><body>404!</body></html>"
  content_type = "text/html"
  bucket       = google_storage_bucket.static_website.id
}
# [END storage_static_website_upload_files_tf]
