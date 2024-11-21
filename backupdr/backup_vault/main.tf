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
  description                                = "This vault is created usingTerraform."
  backup_minimum_enforced_retention_duration = "100000s"
  force_update                               = "true"
  force_delete                               = "true"
  allow_missing                              = "true"
}

# [END backupdr_create_backupvault]
