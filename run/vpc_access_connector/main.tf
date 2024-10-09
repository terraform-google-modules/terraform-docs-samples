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

# [START cloudrun_vpc_access_connector_parent_tag]
# [START vpc_serverless_connector_enable_api]
resource "google_project_service" "vpcaccess_api" {
  service            = "vpcaccess.googleapis.com"
  disable_on_destroy = false
}
# [END vpc_serverless_connector_enable_api]

# [START vpc_serverless_connector]
# VPC
resource "google_compute_network" "default" {
  name                    = "cloudrun-network"
  auto_create_subnetworks = false
}

# VPC access connector
resource "google_vpc_access_connector" "connector" {
  name          = "vpcconn"
  region        = "us-west1"
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.default.name
  depends_on    = [google_project_service.vpcaccess_api]
  min_instances = 2
  max_instances = 3
}

# Cloud Router
resource "google_compute_router" "router" {
  name    = "router"
  region  = "us-west1"
  network = google_compute_network.default.id
}

# NAT configuration
resource "google_compute_router_nat" "router_nat" {
  name                               = "nat"
  region                             = "us-west1"
  router                             = google_compute_router.router.name
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option             = "AUTO_ONLY"
}
# [END vpc_serverless_connector]

# [START cloudrun_vpc_serverless_connector]
# Cloud Run service
resource "google_cloud_run_v2_service" "gcr_service" {
  name     = "mygcrservice"
  location = "us-west1"

  deletion_protection = false # set to "true" in production

  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
      }
      # the service uses this SA to call other Google Cloud APIs
      # service_account_name = myservice_runtime_sa
    }

    scaling {
      # Limit scale up to prevent any cost blow outs!
      max_instance_count = 5
    }

    vpc_access {
      # Use the VPC Connector
      connector = google_vpc_access_connector.connector.id
      # all egress from the service should go through the VPC Connector
      egress = "ALL_TRAFFIC"
    }
  }
}
# [END cloudrun_vpc_serverless_connector]
# [END cloudrun_vpc_access_connector_parent_tag]
