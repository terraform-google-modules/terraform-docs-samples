/**
* Copyright 2024-2025 Google LLC
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

# [START gke_enterprise_config_sync_oci]
resource "google_gke_hub_feature" "configmanagement_feature_member" {
  name     = "configmanagement"
  location = "global"

  fleet_default_member_config {
    configmanagement {
      config_sync {
        # The field `enabled` was introduced in Terraform version 5.41.0, and
        # needs to be set to `true` explicitly to install Config Sync.
        enabled = true
        oci {
          sync_repo   = "REPO"
          policy_dir  = "DIRECTORY"
          secret_type = "SECRET"
        }
      }
    }
  }
}
# [END gke_enterprise_config_sync_oci]
