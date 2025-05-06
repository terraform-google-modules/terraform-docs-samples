/**
 * Copyright 2025 Google LLC
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

# [START mediacdn_custom_headers_parent_tag]
resource "random_id" "unique_suffix" {
  byte_length = 8
}

resource "google_storage_bucket" "default" {
  name                        = "my-bucket-${random_id.unique_suffix.hex}"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_network_services_edge_cache_origin" "default" {
  name           = "cloud-storage-origin"
  origin_address = "gs://my-bucket-${random_id.unique_suffix.hex}"
}

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
        description = "a default route rule with low priority"
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
      # [START mediacdn_custom_headers_route]
      route_rule {
        description = "video routes"
        priority    = 1
        match_rule {
          prefix_match = "/video/"
        }
        origin = google_network_services_edge_cache_origin.default.name
        header_action {
          response_header_to_add {
            # Return the country (or region) associated with the client's IP address.
            header_name  = "client-geo"
            header_value = "{client_region}"
            replace      = true
          }
          request_header_to_add {
            # Inform the upstream origin server that the request is from Media CDN.
            header_name  = "x-downstream-cdn"
            header_value = "Media CDN"
          }
          response_header_to_remove {
            header_name = "X-User-ID"
          }
          response_header_to_remove {
            header_name = "X-Other-Internal-Header"
          }
        }
      }
      # [END mediacdn_custom_headers_route]
    }
  }
}
# [END mediacdn_custom_headers_parent_tag]
