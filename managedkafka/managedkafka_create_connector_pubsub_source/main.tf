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

# [START managedkafka_create_connector_pubsub_source_parent]
data "google_project" "default" {
  provider = google-beta
}

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
        subnet = "projects/${data.google_project.default.number}/regions/us-central1/subnetworks/default"
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
        primary_subnet = "projects/${data.google_project.default.number}/regions/us-central1/subnetworks/default"
      }
    }
  }
}

# [END managedkafka_create_connector_pubsub_source_parent]

# [START managedkafka_create_connector_pubsub_source]
resource "google_managed_kafka_connector" "example-pubsub-source-connector" {
  project         = data.google_project.default.project_id
  connector_id    = "my-pubsub-source-connector"
  connect_cluster = google_managed_kafka_connect_cluster.default.connect_cluster_id
  location        = "us-central1"

  configs = {
    "connector.class"  = "com.google.pubsub.kafka.source.CloudPubSubSourceConnector"
    "name"             = "my-pubsub-source-connector"
    "tasks.max"        = "1"
    "kafka.topic"      = "GMK_TOPIC_ID"
    "cps.subscription" = "CPS_SUBSCRIPTION_ID"
    "cps.project"      = "GCP_PROJECT_ID"
    "value.converter"  = "org.apache.kafka.connect.converters.ByteArrayConverter"
    "key.converter"    = "org.apache.kafka.connect.storage.StringConverter"
  }

  provider = google-beta
}
# [END managedkafka_create_connector_pubsub_source]
