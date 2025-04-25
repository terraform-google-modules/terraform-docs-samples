/**
* Copyright 2024 Google LLC
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

# [START gke_standard_zonal_reservation_any_reservation]
resource "google_compute_reservation" "any_reservation" {
  name = "any-reservation"
  zone = "us-central1-a"

  specific_reservation {
    count = 3

    instance_properties {
      machine_type = "e2-medium"
    }
  }
}
# [END gke_standard_zonal_reservation_any_reservation]

# [START gke_standard_zonal_reservation_any_cluster]
resource "google_container_cluster" "default" {
  name     = "gke-standard-zonal-cluster"
  location = "us-central1-a"

  initial_node_count = 1

  node_config {
    machine_type = "e2-medium"

    reservation_affinity {
      consume_reservation_type = "ANY_RESERVATION"
    }
  }

  depends_on = [
    google_compute_reservation.any_reservation
  ]
}
# [END gke_standard_zonal_reservation_any_cluster]

# [START gke_standard_zonal_reservation_any_node_pool]
resource "google_container_node_pool" "any_node_pool" {
  name     = "gke-standard-zonal-any-node-pool"
  cluster  = google_container_cluster.default.name
  location = google_container_cluster.default.location

  initial_node_count = 3
  node_config {
    machine_type = "e2-medium"

    reservation_affinity {
      consume_reservation_type = "ANY_RESERVATION"
    }
  }
}
# [END gke_standard_zonal_reservation_any_node_pool]

# [START gke_standard_zonal_reservation_specific_reservation]
resource "google_compute_reservation" "specific_reservation" {
  name = "specific-reservation"
  zone = "us-central1-a"

  specific_reservation {
    count = 1

    instance_properties {
      machine_type = "e2-medium"
    }
  }

  specific_reservation_required = true
}
# [END gke_standard_zonal_reservation_specific_reservation]

# [START gke_standard_zonal_reservation_specific_node_pool]
resource "google_container_node_pool" "specific_node_pool" {
  name     = "gke-standard-zonal-specific-node-pool"
  cluster  = google_container_cluster.default.name
  location = google_container_cluster.default.location

  initial_node_count = 1
  node_config {
    machine_type = "e2-medium"

    reservation_affinity {
      consume_reservation_type = "SPECIFIC_RESERVATION"
      key                      = "compute.googleapis.com/reservation-name"
      values                   = [google_compute_reservation.specific_reservation.name]
    }
  }

  depends_on = [
    google_compute_reservation.specific_reservation
  ]
}
# [END gke_standard_zonal_reservation_specific_node_pool]

# [START gke_standard_zonal_reservation_flex]
resource "google_container_node_pool" "reservation_flex" {
  provider = google-beta
  name     = "gke_standard_zonal_reservation_flex"
  cluster  = google_container_cluster.default.name
  location = google_container_cluster.default.location

  initial_node_count = 0
  autoscaling {
    total_min_node_count = 0
    total_max_node_count = 1
  }
  node_config {
    machine_type     = "e2-medium"
    flex_start       = true
    max_run_duration = "604800s"

    reservation_affinity {
      consume_reservation_type = "NO_RESERVATION"
    }
  }
}
# [END gke_standard_zonal_reservation_flex]
