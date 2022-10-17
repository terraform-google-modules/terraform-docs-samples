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

# VPC network
resource "google_compute_network" "default" {
  provider                = google-beta
  name                    = "vpc-network"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "default" {
  provider      = google-beta
  name          = "vpc-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west1"
  network       = google_compute_network.default.id
}

# [START cloud_sql_sqlserver_vm_instance]
resource "google_compute_instance" "sqlserver_vm" {
  provider = google-beta
  name     = "sqlserver-vm"
  boot_disk {
    auto_delete = true
    device_name = "persistent-disk-0"
    initialize_params {
      image = "windows-sql-cloud/sql-std-2019-win-2022"
      size  = 50
      type  = "pd-balanced"
    }
    mode = "READ_WRITE"
  }
  machine_type = "n1-standard-4"
  zone         = "europe-west1-b"
  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }
    network    = google_compute_network.default.id
    stack_type = "IPV4_ONLY"
    subnetwork = google_compute_subnetwork.default.id
  }
}
# [END cloud_sql_sqlserver_vm_instance]

# [START cloud_sql_sqlserver_vm_firewall_rule]
resource "google_compute_firewall" "sql_server_1433" {
  provider = google-beta
  name     = "sql-server-1433-3"
  allow {
    ports    = ["1433"]
    protocol = "tcp"
  }
  description   = "Allow SQL Server access from all sources on port 1433."
  direction     = "INGRESS"
  network       = google_compute_network.default.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
}
# [END cloud_sql_sqlserver_vm_firewall_rule]
