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
# [START backupdr_create_backupvault]

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

  force_update                = "true"
  ignore_inactive_datasources = "true"
  allow_missing               = "true"
}

# [END backupdr_create_backupvault]

# [START backupdr_create_backupplan]

# Before creating a backup plan, you need to create backup vault (google_backup_dr_backup_vault).
resource "google_backup_dr_backup_plan" "default" {
  provider       = google-beta
  location       = "us-central1"
  backup_plan_id = "my-bp"
  resource_type  = "compute.googleapis.com/Instance"
  backup_vault   = google_backup_dr_backup_vault.default.name

  backup_rules {
    rule_id               = "rule-1"
    backup_retention_days = 5

    standard_schedule {
      recurrence_type  = "HOURLY"
      hourly_frequency = 6
      time_zone        = "UTC"

      backup_window {
        start_hour_of_day = 0
        end_hour_of_day   = 24
      }
    }
  }
}

# [END backupdr_create_backupplan]
