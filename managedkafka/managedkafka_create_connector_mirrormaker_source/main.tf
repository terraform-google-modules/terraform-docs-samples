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

# [START managedkafka_create_connector_mirrormaker_source_parent]

resource "google_managed_kafka_cluster" "default" {
  project    = data.google_project.default.project_id
  cluster_id = "my-cluster-id"
  location   = "us-central1"
  capacity_config {
    vcpu_count   = 3
    memory_bytes = 3221225472 # 3 GiB
  }
  gcp_config {
    access_config {
      network_configs {
        subnet = google_compute_subnetwork.default.id
      }
    }
  }
}

resource "google_managed_kafka_connect_cluster" "default" {
  provider           = google-beta
  project            = data.google_project.default.project_id
  connect_cluster_id = "my-connect-cluster-id"
  location           = "us-central1"
  kafka_cluster      = google_managed_kafka_cluster.default.id
  capacity_config {
    vcpu_count   = 12
    memory_bytes = 12884901888 # 12 GiB
  }
  gcp_config {
    access_config {
      network_configs {
        primary_subnet = google_compute_subnetwork.default.id
      }
    }
  }
}

# Note: Due to a known issue, network attachment resources may not be
# properly deleted, which can cause 'terraform destroy' to hang. It is
# recommended to destroy network resources separately from the Kafka
# Connect resources.
# The documentation elaborates further on the recommended approach.
# [START managedkafka_subnetwork]
resource "google_compute_subnetwork" "default" {
  name          = "test-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.default.id
}

resource "google_compute_network" "default" {
  name                    = "test-network"
  auto_create_subnetworks = false
}
# [END managedkafka_subnetwork]

# [START managedkafka_create_connector_mirrormaker_source]
resource "google_managed_kafka_connector" "default" {
  project         = data.google_project.default.project_id
  connector_id    = "MM2_CONNECTOR_ID"
  connect_cluster = google_managed_kafka_connect_cluster.default.connect_cluster_id
  location        = "us-central1"

  configs = {
    "connector.class"                  = "org.apache.kafka.connect.mirror.MirrorSourceConnector"
    "name"                             = "MM2_CONNECTOR_ID"
    "tasks.max"                        = "3"
    "source.cluster.alias"             = "source"
    "target.cluster.alias"             = "target" # This is usually the primary cluster
    "topics"                           = "GMK_TOPIC_NAME"
    "source.cluster.bootstrap.servers" = "GMK_SOURCE_CLUSTER_DNS"
    "target.cluster.bootstrap.servers" = "GMK_TARGET_CLUSTER_DNS"
  }

  provider = google-beta
}
# [END managedkafka_create_connector_mirrormaker_source]

data "google_project" "default" {
}

# [END managedkafka_create_connector_mirrormaker_source_parent]
