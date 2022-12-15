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
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or 
implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# [START iam_service_account_for_vm]
resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}
# [END iam_service_account_for_vm]

# [START compute_instance_run_as_service_account]
resource "google_compute_instance" "default" {
  name         = "my-test-vm"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    # Google recommends custom service accounts with cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}
# [END compute_instance_run_as_service_account]
