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

# [START managedkafkaconnect_create_cluster_parent]
resource "google_managed_kafka_cluster" "example-kafka-cluster" {
  project    = data.google_project.default.project_id
  cluster_id = "my-cluster-id"
  location   = "us-central1"
  capacity_config {
    vcpu_count   = 3
    memory_bytes = 3221225472
  }
  gcp_config {
    access_config {
      network_configs {
        subnet = "projects/${data.google_project.default.number}/regions/us-central1/subnetworks/default"
      }
    }
  }
}

# [START managedkafkaconnect_create_cluster]
resource "google_managed_kafka_connect_cluster" "example-kafka-connect-cluster" {
  provider           = google-beta
  project            = data.google_project.default.project_id # Replace this with your project ID in quotes
  connect_cluster_id = "my-connect-cluster-id"
  location           = "us-central1"
  kafka_cluster      = google_managed_kafka_cluster.example-kafka-cluster.id
  capacity_config {
    vcpu_count   = 12
    memory_bytes = 21474836480
  }
  gcp_config {
    access_config {
      network_configs {
        primary_subnet = "projects/${data.google_project.default.number}/regions/us-central1/subnetworks/default"
      }
    }
  }
  depends_on = [
    google_managed_kafka_cluster.example-kafka-cluster
  ]
}
# [END managedkafkaconnect_create_cluster]

data "google_project" "default" {
  provider = google-beta
}
# [END managedkafkaconnect_create_cluster_parent]