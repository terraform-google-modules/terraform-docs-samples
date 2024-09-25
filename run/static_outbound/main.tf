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

# Enable Compute Engine API
# [START cloudrun_static_outbound_parent_tag]
resource "google_project_service" "compute_engine_api" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# Enable Cloud Run API
resource "google_project_service" "cloudrun_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# Example of setting up a Cloud Run service with a static outbound IP
# [START cloudrun_service_static_network]
resource "google_compute_network" "default" {
  name = "cr-static-ip-network"
}
# [END cloudrun_service_static_network]

# [START cloudrun_service_static_subnet]
resource "google_compute_subnetwork" "default" {
  name          = "cr-static-ip"
  ip_cidr_range = "10.124.0.0/28"
  network       = google_compute_network.default.id
  region        = "us-central1"
}
# [END cloudrun_service_static_subnet]

# [START cloudrun_service_static_vpc_conn]
resource "google_project_service" "vpc" {
  service            = "vpcaccess.googleapis.com"
  disable_on_destroy = false
}

resource "google_vpc_access_connector" "default" {
  name          = "cr-conn"
  region        = "us-central1"
  min_instances = 2
  max_instances = 3

  subnet {
    name = google_compute_subnetwork.default.name
  }

  # Wait for VPC API enablement
  # before creating this resource
  depends_on = [
    google_project_service.vpc
  ]
}
# [END cloudrun_service_static_vpc_conn]

# [START cloudrun_service_static_router]
resource "google_compute_router" "default" {
  name    = "cr-static-ip-router"
  network = google_compute_network.default.name
  region  = google_compute_subnetwork.default.region
}
# [END cloudrun_service_static_router]

# [START cloudrun_service_static_addr]
resource "google_compute_address" "default" {
  name   = "cr-static-ip-addr"
  region = google_compute_subnetwork.default.region
}
# [END cloudrun_service_static_addr]

# [START cloudrun_service_static_nat]
resource "google_compute_router_nat" "default" {
  name   = "cr-static-nat"
  router = google_compute_router.default.name
  region = google_compute_subnetwork.default.region

  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = [google_compute_address.default.self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.default.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
# [END cloudrun_service_static_nat]

# [START cloudrun_service_static_service]
resource "google_cloud_run_v2_service" "default" {
  name     = "cr-static-ip-service"
  location = google_compute_subnetwork.default.region

  deletion_protection = false # set to "true" in production

  template {
    containers {
      # Replace with the URL of your container
      #   gcr.io/<YOUR_GCP_PROJECT_ID>/<YOUR_CONTAINER_NAME>
      image = "us-docker.pkg.dev/cloudrun/container/hello"
    }
    scaling {
      max_instance_count = 5
    }
    vpc_access {
      connector = google_vpc_access_connector.default.id
      egress    = "ALL_TRAFFIC"
    }
  }
  ingress = "INGRESS_TRAFFIC_ALL"

  # [END cloudrun_service_static_service]
  # Used in sample testing. These fields may change in 'terraform plan' output, which is expected and thus non-blocking.
  lifecycle {
    ignore_changes = [
      ingress, template[0].vpc_access
    ]
  }
  # [START cloudrun_service_static_service]
}
# [END cloudrun_service_static_service]
# [END cloudrun_static_outbound_parent_tag]
