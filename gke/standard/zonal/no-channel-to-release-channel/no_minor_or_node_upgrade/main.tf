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

# [START gke_standard_release_channel_no_minor_or_node_upgrade]
resource "google_container_cluster" "default" {
  name     = "cluster-zonal-example-none-to-rc"
  location = "us-central1-f"

  release_channel {
    channel = "REGULAR"
  }

  maintenance_policy {
    recurring_window {
      start_time = "2025-02-11T19:16:39Z"
      end_time   = "2025-02-11T23:16:39Z"
      recurrence = "FREQ=DAILY"
    }
    maintenance_exclusion {
      exclusion_name = "no_minor_or_node_upgrades_exclusion"
      # NOTE: Pick an interval for your exclusion with an end_time in the future
      # otherwise the exclusion will have no effect.
      # This example assumes that the exclusion is set on 2025-02-11.
      start_time = "2025-02-11T23:16:39Z"
      # This the end of standard support for 1.31.
      end_time = "2025-12-22T00:00:00Z"
      exclusion_options {
        scope = "NO_MINOR_OR_NODE_UPGRADES"
      }
    }
  }

  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "default" {
  name    = "cluster-zonal-example-none-to-rc-np"
  cluster = google_container_cluster.default.id

  node_count = 2

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
# [END gke_standard_release_channel_no_minor_or_node_upgrade]
