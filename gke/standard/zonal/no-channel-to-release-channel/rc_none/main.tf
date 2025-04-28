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

# NOTE: Locations are different in these examples to satisfy the tests.
# These are intended to represent sequential steps on the same cluster.

# [START gke_standard_release_channel_none]
resource "google_container_cluster" "default" {
  name     = "cluster-zonal-example-none-to-rc"
  location = "us-central1-a"

  release_channel {
    channel = "UNSPECIFIED"
  }

  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "default" {
  name    = "cluster-zonal-example-none-to-rc-np"
  cluster = google_container_cluster.default.id

  node_count = 2

  management {
    auto_repair  = false
    auto_upgrade = false
  }
}
# [END gke_standard_release_channel_none]
