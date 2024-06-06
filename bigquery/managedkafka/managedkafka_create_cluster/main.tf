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

# [START managedkafka_create_cluster_parent]
# [START managedkafka_create_cluster]
resource "google_managed_kafka_cluster" "default" {
  cluster_id = "my-cluster-id"
  location   = "us-central1"
  capacity_config {
    vcpu_count   = 3
    memory_bytes = 3221225472
  }
  gcp_config {
    access_config {
      network_configs {
        subnet = "projects/${data.google_project.project.number}/regions/us-central1/subnetworks/default"
      }
    }
  }

  depends_on = [google_project_service.managedkafka]

  provider = google-beta
}
# [END managedkafka_create_cluster]

# [START managedkafka_enable_service]
resource "google_project_service" "managedkafka" {
  project            = data.google_project.project.project_id
  service            = "managedkafka.googleapis.com"
  disable_on_destroy = false

  provider = google-beta
}
# [END managedkafka_enable_service]

data "google_project" "project" {
  provider = google-beta
}
# [END managedkafka_create_cluster_parent]
