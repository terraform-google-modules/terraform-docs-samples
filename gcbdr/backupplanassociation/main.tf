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

# [START backupdr_create_backupplanassociation]

// Before creating a backup plan association, you need to create backup plan(google_backup_dr_backup_plan)
and compute instance (google_compute_instance). 
resource "google_backup_dr_backup_plan_association" "default" { 
  provider = google-beta
  location = "us-central1" 
  backup_plan_association_id = "tf-test-bpa-test"
  resource =   google_compute_instance.default.id
  resource_type= "compute.googleapis.com/Instance"
  backup_plan = google_backup_dr_backup_plan.foo.name
}
# [END backupdr_create_backupplanassociation]