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

# Terraform Registry: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_services_edge_cache_service
# Google Cloud Documentation
#   1. https://cloud.google.com/media-cdn/docs/quickstart#create-service
#   2. https://cloud.google.com/media-cdn/docs/origins#cloud-storage-origins

# [START mediacdn_quickstart_parent_tag]
resource "google_storage_bucket" "default" {
  name                        = "my-bucket-123123"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}

# [START mediacdn_edge_cache_origin]
resource "google_network_services_edge_cache_origin" "default" {
  name           = "cloud-storage-origin"
  origin_address = "gs://my-bucket-123123" # Update bucket name
  description    = "Media Edge Origin with Cloud Storage as Origin"
  max_attempts   = 3 # Min is 1s, Default is 1s & Max 3
  timeout {
    connect_timeout  = "10s"  # Min is 1s, Default is 5s & Max 15s
    response_timeout = "120s" # Min is 1s, Default is 30s & Max 120s
    read_timeout     = "5s"   # Min is 1s, Default is 15s & Max 30s
  }
}
# [END mediacdn_edge_cache_origin]

# [START mediacdn_edge_cache_service]
resource "google_network_services_edge_cache_service" "default" {
  name        = "cloud-media-service"
  description = "Media Edge Service with Cloud Storage as Origin"
  routing {
    host_rule {
      description  = "host rule description"
      hosts        = ["googlecloudexample.com"]
      path_matcher = "routes"
    }
    path_matcher {
      name = "routes"
      route_rule {
        description = "a route rule to match against"
        priority    = 1
        match_rule {
          prefix_match = "/"
        }
        # Referring to previously defined Edge Cache Origin
        origin = google_network_services_edge_cache_origin.default.name
        route_action {
          cdn_policy {
            cache_mode  = "CACHE_ALL_STATIC"
            default_ttl = "3600s"
          }
        }
        header_action {
          response_header_to_add {
            header_name  = "x-cache-status"
            header_value = "{cdn_cache_status}"
          }
        }
      }
    }
  }
}
# [END mediacdn_edge_cache_service]
# [END mediacdn_quickstart_parent_tag]
