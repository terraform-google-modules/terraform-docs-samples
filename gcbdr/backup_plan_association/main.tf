/**
* Copyright 2024 Google LLC
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

resource "google_service_account" "default" {
  provider     = google-beta
  account_id   = "my-sa"
  display_name = "Custom SA for VM Instance"
}

resource "google_compute_instance" "default" {
  provider     = google-beta
  name         = "my-instance"
  machine_type = "n2-standard-2"
  zone         = "us-central1-a"
  tags         = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

resource "google_backup_dr_backup_vault" "default" {
  provider                                   = google-beta
  location                                   = "us-central1"
  backup_vault_id                            = "my-vault"
  description                                = "This is a second backup vault built by Terraform."
  backup_minimum_enforced_retention_duration = "100000s"

  labels = {
    foo = "bar1"
    bar = "baz1"
  }

  annotations = {
    annotations1 = "bar1"
    annotations2 = "baz1"
  }

  force_update  = "true"
  force_delete  = "true"
  allow_missing = "true"
}

resource "google_backup_dr_backup_plan" "default" {
  provider       = google-beta
  location       = "us-central1"
  backup_plan_id = "my-bp"
  resource_type  = "compute.googleapis.com/Instance"
  backup_vault   = google_backup_dr_backup_vault.default.name

  backup_rules {
    rule_id               = "rule-1"
    backup_retention_days = 2

    standard_schedule {
      recurrence_type  = "HOURLY"
      hourly_frequency = 6
      time_zone        = "UTC"

      backup_window {
        start_hour_of_day = 12
        end_hour_of_day   = 18
      }
    }
  }
}

# [START backupdr_create_backupplanassociation]

# Before creating a backup plan association, you need to create backup plan (google_backup_dr_backup_plan)
# and compute instance (google_compute_instance).
resource "google_backup_dr_backup_plan_association" "default" {
  provider                   = google-beta
  location                   = "us-central1"
  backup_plan_association_id = "my-bpa"
  resource                   = google_compute_instance.default.id
  resource_type              = "compute.googleapis.com/Instance"
  backup_plan                = google_backup_dr_backup_plan.default.name
}

# [END backupdr_create_backupplanassociation]
