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
resource "google_container_cluster" "rc_none" {
  name     = "cluster-zonal-example-none-to-rc"
  location = "us-central1-a"

  release_channel {
    channel = "UNSPECIFIED"
  }

  remove_default_node_pool = true
  initial_node_count       = 1

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}

resource "google_container_node_pool" "rc_none" {
  name    = "cluster-zonal-example-none-to-rc-np"
  cluster = google_container_cluster.rc_none.name

  node_count = 2

  management {
    auto_repair  = false
    auto_upgrade = false
  }
}
# [END gke_standard_release_channel_none]

# [START gke_standard_release_channel_no_upgrade]
resource "google_container_cluster" "no_upgrade" {
  name     = "cluster-zonal-example-none-to-rc"
  location = "us-central1-b"

  release_channel {
    channel = "UNSPECIFIED"
  }

  maintenance_policy {
    # A recurring window must be set to use maintenance exclusions in Terraform.
    recurring_window {
      start_time = "2025-02-11T19:16:39Z"
      end_time   = "2025-02-11T23:16:39Z"
      recurrence = "FREQ=DAILY"
    }
    maintenance_exclusion {
      exclusion_name = "no_upgrades_exclusion"
      start_time     = "2025-02-11T23:16:39Z"
      # NO_UPGRADES exclusions are limited to 30 days.
      end_time = "2025-03-11T23:16:39Z"
      exclusion_options {
        scope = "NO_UPGRADES"
      }
    }
  }

  remove_default_node_pool = true
  initial_node_count       = 1

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}

resource "google_container_node_pool" "no_upgrade" {
  name    = "cluster-zonal-example-none-to-rc-np"
  cluster = google_container_cluster.no_upgrade.name

  node_count = 2

  management {
    auto_repair  = false
    auto_upgrade = false
  }
}
# [END gke_standard_release_channel_no_upgrade]

# [START gke_standard_release_channel_rc_regular]
resource "google_container_cluster" "rc_regular" {
  name     = "cluster-zonal-example-none-to-rc"
  location = "us-central1-c"

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
      exclusion_name = "no_upgrades_exclusion"
      start_time     = "2025-02-11T23:16:39Z"
      end_time       = "2025-03-11T23:16:39Z"
      exclusion_options {
        scope = "NO_UPGRADES"
      }
    }
  }

  remove_default_node_pool = true
  initial_node_count       = 1

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}

resource "google_container_node_pool" "rc_regular" {
  name    = "cluster-zonal-example-none-to-rc-np"
  cluster = google_container_cluster.rc_regular.id

  node_count = 2

  management {
    # Auto-repair and auto-upgrade should be set to true when moving to a
    # release channel.
    auto_repair  = true
    auto_upgrade = true
  }
}
# [END gke_standard_release_channel_rc_regular]

# [START gke_standard_release_channel_no_minor_or_node_upgrade]
resource "google_container_cluster" "no_minor_or_node_upgrade" {
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
      start_time     = "2025-02-11T23:16:39Z"
      # This the end of standard support for 1.31.
      end_time = "2025-12-22T00:00:00Z"
      exclusion_options {
        scope = "NO_MINOR_OR_NODE_UPGRADES"
      }
    }
  }

  remove_default_node_pool = true
  initial_node_count       = 1

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}

resource "google_container_node_pool" "no_minor_or_node_upgrade" {
  name    = "cluster-zonal-example-none-to-rc-np"
  cluster = google_container_cluster.no_minor_or_node_upgrade.name

  node_count = 2

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
# [END gke_standard_release_channel_no_minor_or_node_upgrade]
