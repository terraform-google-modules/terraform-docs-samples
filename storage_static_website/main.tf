# [START storage_static_website_tf]
# Create new storage bucket in the US multi-region
# with coldline storage and settings for main_page_suffix and not_found_page
resource "google_storage_bucket" "static_website" {
    name          = "static-website-bucket"
    location      = "US"
    storage_class = "COLDLINE"
    website {
        main_page_suffix = "index.html"
        not_found_page = "index.html"
    }
}

# Make bucket public by granting allUsers READER access
resource "google_storage_bucket_access_control" "public_rule" {
  bucket = google_storage_bucket.static_website.id
  role   = "READER"
  entity = "allUsers"
}

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
# [END storage_static_website_tf]
