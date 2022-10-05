# [START cloudloadbalancing_global_ext_bucket_buckets]
# Create Cloud Storage buckets
resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "bucket_1" {
  name                        = "${random_id.bucket_prefix.hex}-bucket-1"
  location                    = "us-east1"
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  // delete bucket and contents on destroy.
  force_destroy = true
}

resource "google_storage_bucket" "bucket_2" {
  name                        = "${random_id.bucket_prefix.hex}-bucket-2"
  location                    = "us-east1"
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  // delete bucket and contents on destroy.
  force_destroy = true
}
# [END cloudloadbalancing_global_ext_bucket_buckets]


# [START cloudloadbalancing_global_ext_bucket_files]
# image object for testing, try to access http://<your_lb_ip_address>/test.jpg
resource "google_storage_bucket_object" "cat_image" {
  name         = "never-fetch/three-cats.jpg"
  source       = "images/three-cats.jpg"
  content_type = "image/jpeg"

  bucket = google_storage_bucket.bucket_1.name
}

resource "google_storage_bucket_object" "dog_image" {
  name         = "love-to-fetch/two-dogs.jpg"
  source       = "images/two-dogs.jpg"
  content_type = "image/jpeg"

  bucket = google_storage_bucket.bucket_2.name
}
# [END cloudloadbalancing_global_ext_bucket_files]


# [START cloudloadbalancing_global_ext_bucket_public]  
# Make buckets public
resource "google_storage_bucket_iam_member" "bucket_1" {
  bucket = google_storage_bucket.bucket_1.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
# [END cloudloadbalancing_global_ext_bucket_public]

resource "google_storage_bucket_iam_member" "bucket_2" {
  bucket = google_storage_bucket.bucket_2.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
# [END cloudloadbalancing_global_ext_bucket_public]

# [START cloudloadbalancing_global_ext_bucket_ip]
# Reserve IP address
resource "google_compute_global_address" "default" {
  name = "example-ip"
}
# [END cloudloadbalancing_global_ext_bucket_ip]

# [START cloudloadbalancing_global_ext_bucket_backends]
# Create LB backend buckets
resource "google_compute_backend_bucket" "bucket_1" {
  name        = "cats"
  description = "Contains cat image"
  bucket_name = google_storage_bucket.bucket_1.name
}

resource "google_compute_backend_bucket" "bucket_2" {
  name        = "dogs"
  description = "Contains dog image"
  bucket_name = google_storage_bucket.bucket_2.name
}
# [END cloudloadbalancing_global_ext_bucket_backends]

# [START cloudloadbalancing_global_ext_bucket_urlmap]
# Create url map
resource "google_compute_url_map" "default" {
  name = "http-lb"

  default_service = google_compute_backend_bucket.bucket_1.id

  host_rule {
    hosts        = ["*"]
    path_matcher = "path-matcher-2"
  }
  path_matcher {
    name            = "path-matcher-2"
    default_service = google_compute_backend_bucket.bucket_1.id

    path_rule {
      paths   = ["/love-to-fetch/*"]
      service = google_compute_backend_bucket.bucket_2.id
    }
  }
}
# [END cloudloadbalancing_global_ext_bucket_urlmap]

# [START cloudloadbalancing_global_ext_bucket_target_http_proxy] 
# Create HTTP target proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.default.id
}
# [END cloudloadbalancing_global_ext_bucket_target_http_proxy]

# [START cloudloadbalancing_global_ext_bucket_forwarding_rule]
# Create forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "http-lb-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}
# [END cloudloadbalancing_global_ext_bucket_forwarding_rule]
