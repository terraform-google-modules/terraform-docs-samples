/**
* Copyright 2026 Google LLC
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

/*
Create a GKE cluster with the Managed OpenTelemetry feature
in the us-west1 region.

See https://docs.cloud.google.com/kubernetes-engine/docs/concepts/managed-otel-gke
before running the code snippet.
*/
# [START gke_standard_regional_with_managed_otel]
terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 7.17.0"
    }
  }
}

resource "google_container_cluster" "default" {
  name     = "gke-standard-regional-with-managed-otel"
  provider = google-beta
  location = "us-west1"

  initial_node_count = 1
  release_channel {
    channel = "RAPID" # The default rapid version already has the feature available.
  }

  managed_opentelemetry_config {
    scope = "COLLECTION_AND_INSTRUMENTATION_COMPONENTS"
  }
}
# [END gke_standard_regional_with_managed_otel]
