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
resource "random_id" "unique_suffix" {
  byte_length = 8
}

resource "google_storage_bucket" "default" {
  name                        = "my-bucket-${random_id.unique_suffix.hex}"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}

# [START mediacdn_edge_cache_origin]
resource "google_network_services_edge_cache_origin" "default" {
  name           = "cloud-storage-origin"
  origin_address = "gs://my-bucket-${random_id.unique_suffix.hex}"
}
# [END mediacdn_edge_cache_origin]

# [START mediacdn_edge_cache_service]
resource "google_network_services_edge_cache_service" "default" {
  name = "cloud-media-service"
  routing {
    host_rule {
      hosts        = ["googlecloudexample.com"]
      path_matcher = "routes"
    }
    path_matcher {
      name = "routes"
      route_rule {
        description = "a simple route rule, priority=10 (low)"
        priority    = 10
        match_rule {
          prefix_match = "/"
        }
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
      // for other advanced features examples see:
      // https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/network_services_edge_cache_service
      route_rule {
        description = "an advanced route rule, priority=1 (high)"
        priority    = 1
        match_rule {
          prefix_match = "/advanced"
        }
        origin = google_network_services_edge_cache_origin.default.name
        route_action {
          cdn_policy {
            cache_mode  = "CACHE_ALL_STATIC"
            default_ttl = "3600s"
          }
          url_rewrite {
            path_prefix_rewrite = "/"
          }
          compression_mode = "AUTOMATIC"
        }
        route_methods {
          allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]
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
