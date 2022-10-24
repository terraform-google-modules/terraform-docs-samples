/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# CDN load balancer with Cloud bucket as backend

# [START cloudloadbalancing_cdn_with_backend_bucket_cloud_storage_bucket]
# Cloud Storage bucket
resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "default" {
  name                        = "${random_id.bucket_prefix.hex}-my-bucket"
  location                    = "us-east1"
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
  // delete bucket and contents on destroy.
  force_destroy = true
  // Assign specialty files
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

# [END cloudloadbalancing_cdn_with_backend_bucket_cloud_storage_bucket]

# [START cloudloadbalancing_cdn_with_backend_bucket_make_public]
# make bucket public
resource "google_storage_bucket_iam_member" "default" {
  bucket = google_storage_bucket.default.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
# [END cloudloadbalancing_cdn_with_backend_bucket_make_public]

# [START cloudloadbalancing_cdn_with_backend_bucket_index_page]
resource "google_storage_bucket_object" "index_page" {
  name    = "index-page"
  bucket  = google_storage_bucket.default.name
  content = <<-EOT
    <html><body>
    <h1>Congratulations on setting up Google Cloud CDN with Storage backend!</h1>
    </body></html>
  EOT
}
# [END cloudloadbalancing_cdn_with_backend_bucket_index_page]

# [START cloudloadbalancing_cdn_with_backend_bucket_error_page]
resource "google_storage_bucket_object" "error_page" {
  name    = "404-page"
  bucket  = google_storage_bucket.default.name
  content = <<-EOT
    <html><body>
    <h1>404 Error: Object you are looking for is no longer available!</h1>
    </body></html>
  EOT
}
# [END cloudloadbalancing_cdn_with_backend_bucket_error_page]

# [START cloudloadbalancing_cdn_with_backend_bucket_image]
# image object for testing, try to access http://<your_lb_ip_address>/test.jpg
resource "google_storage_bucket_object" "test_image" {
  name = "test-object"
  # Uncomment and add valid path to an object.
  #  source       = "/path/to/an/object"
  #  content_type = "image/jpeg"

  # Delete after uncommenting above source and content_type attributes
  content      = "Data as string to be uploaded"
  content_type = "text/plain"

  bucket = google_storage_bucket.default.name
}
# [END cloudloadbalancing_cdn_with_backend_bucket_image]

# [START cloudloadbalancing_cdn_with_backend_bucket_ip_address]
# reserve IP address
resource "google_compute_global_address" "default" {
  name = "example-ip"
}
# [END cloudloadbalancing_cdn_with_backend_bucket_ip_address]

# [START cloudloadbalancing_cdn_with_backend_bucket_forwarding_rule]
# forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "http-lb-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}
# [END cloudloadbalancing_cdn_with_backend_bucket_forwarding_rule]

# [START cloudloadbalancing_cdn_with_backend_bucket_http_proxy]
# http proxy
resource "google_compute_target_http_proxy" "default" {
  name    = "http-lb-proxy"
  url_map = google_compute_url_map.default.id
}
# [END cloudloadbalancing_cdn_with_backend_bucket_http_proxy]

# [START cloudloadbalancing_cdn_with_backend_bucket_url_map]
# url map
resource "google_compute_url_map" "default" {
  name            = "http-lb"
  default_service = google_compute_backend_bucket.default.id
}
# [END cloudloadbalancing_cdn_with_backend_bucket_url_map]

# [START cloudloadbalancing_cdn_with_backend_bucket_backend_bucket]
# backend bucket with CDN policy with default ttl settings
resource "google_compute_backend_bucket" "default" {
  name        = "cat-backend-bucket"
  description = "Contains beautiful images"
  bucket_name = google_storage_bucket.default.name
  enable_cdn  = true
  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    client_ttl        = 3600
    default_ttl       = 3600
    max_ttl           = 86400
    negative_caching  = true
    serve_while_stale = 86400
  }
}
# [END cloudloadbalancing_cdn_with_backend_bucket_backend_bucket]
