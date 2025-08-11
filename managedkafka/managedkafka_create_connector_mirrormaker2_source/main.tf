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

# [START managedkafka_create_connector_mirrormaker2_source_parent]

# Define the target Kafka cluster. This is where data will be replicated to.
resource "google_managed_kafka_cluster" "target" {
  project    = data.google_project.default.project_id
  cluster_id = "mm2-target-cluster-id"
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

# Define the source Kafka cluster.
resource "google_managed_kafka_cluster" "source" {
  project    = data.google_project.default.project_id
  cluster_id = "mm2-source-cluster-id"
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
  # The Connect cluster is usually co-located with the target Kafka cluster.
  kafka_cluster = google_managed_kafka_cluster.target.id
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

# [START managedkafka_create_connector_mirrormaker2_source]
# A single MirrorMaker 2 Source Connector to replicate from one source to one target.
resource "google_managed_kafka_connector" "default" {
  project         = data.google_project.default.project_id
  connector_id    = "mm2-source-to-target-connector-id"
  connect_cluster = google_managed_kafka_connect_cluster.default.connect_cluster_id
  location        = "us-central1"

  configs = {
    "connector.class"      = "org.apache.kafka.connect.mirror.MirrorSourceConnector"
    "name"                 = "mm2-source-to-target-connector-id"
    "tasks.max"            = "3"
    "source.cluster.alias" = "source"
    "target.cluster.alias" = "target"
    "topics"               = ".*" # Replicate all topics from the source
    # The value for bootstrap.servers is a comma-separated list of hostname:port pairs for one
    # or more Kafka brokers in the source/target cluster.
    "source.cluster.bootstrap.servers" = "source_cluster_dns"
    "target.cluster.bootstrap.servers" = "target_cluster_dns"
    # Using a replication policy is a good practice to identify mirrored topics.
    # It prefixes the topic name with the source alias (e.g., "source.my-topic").
    "replication.policy.class" = "org.apache.kafka.connect.mirror.DefaultReplicationPolicy"
  }

  provider = google-beta
}
# [END managedkafka_create_connector_mirrormaker2_source]

data "google_project" "default" {
}

# [END managedkafka_create_connector_mirrormaker2_source_parent]
