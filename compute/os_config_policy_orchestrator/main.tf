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

# [START osconfig_policy_orchestrator]
data "google_project" "project" {}

resource "google_project_service" "osconfig" {
  service            = "osconfig.googleapis.com"
  project            = data.google_project.project.project_id
  disable_on_destroy = false
}
resource "google_project_service" "progressiverollout" {
  service            = "progressiverollout.googleapis.com"
  project            = data.google_project.project.project_id
  disable_on_destroy = false
}

# Provision the OS Config and Progressive Rollout service agents before creating
# the policy orchestrator because new projects do not mint them automatically.
resource "google_project_service_identity" "osconfig" {
  provider = google-beta
  service  = google_project_service.osconfig.service
  project  = data.google_project.project.project_id
}
resource "google_project_service_identity" "progressiverollout" {
  provider = google-beta
  service  = google_project_service.progressiverollout.service
  project  = data.google_project.project.project_id
}

# Generating a service identity does not attach default IAM roles, so grant
# each service agent its required role on the project.
resource "google_project_iam_member" "osconfig" {
  project = data.google_project.project.project_id
  role    = "roles/osconfig.serviceAgent"
  member  = google_project_service_identity.osconfig.member
}
# Generating the osconfig.googleapis.com service identity also creates the
# secondary gcp-sa-osconfig-rollout service agent, which is not exposed on .member.
resource "google_project_iam_member" "osconfig_rollout" {
  project = data.google_project.project.project_id
  role    = "roles/osconfig.rolloutServiceAgent"
  member  = "serviceAccount:service-${data.google_project.project.number}@gcp-sa-osconfig-rollout.iam.gserviceaccount.com"
  depends_on = [google_project_service_identity.osconfig]
}
resource "google_project_iam_member" "progressiverollout" {
  project = data.google_project.project.project_id
  role    = "roles/progressiverollout.serviceAgent"
  member  = google_project_service_identity.progressiverollout.member
}

resource "google_os_config_v2_policy_orchestrator" "default" {
  policy_orchestrator_id = "example-policy-orchestrator"
  action                 = "UPSERT"
  state                  = "ACTIVE"
  description            = "Policy orchestrator targeting specific projects and Compute Engine zones."
  orchestration_scope {
    # Define each selector type in a separate selectors block because each
    # selectors block accepts only one selector type. Multiple selectors blocks
    # combine with a logical AND to restrict the orchestration scope.
    selectors {
      resource_hierarchy_selector {
        # resource_hierarchy_selector requires project numbers prefixed with "projects/".
        included_projects = ["projects/${data.google_project.project.number}"]
      }
    }
    selectors {
      location_selector {
        included_locations = ["us-central1-a", "us-central1-b"]
      }
    }
  }
  orchestrated_resource {
    id = "example-os-policy-assignment"
    os_policy_assignment_v1_payload {
      description = "Verify that the /etc/debian_version file is present on Debian VMs."
      os_policies {
        id   = "example-os-policy"
        mode = "VALIDATION"
        resource_groups {
          resources {
            id = "example-file-resource"
            file {
              # Setting state to "PRESENT" checks only whether the file exists.
              # The content field is required by the API schema when state is not "ABSENT".
              path    = "/etc/debian_version"
              state   = "PRESENT"
              content = "example-configuration-content"
            }
          }
        }
      }
      instance_filter {
        inventories {
          os_short_name = "debian"
        }
      }
      rollout {
        min_wait_duration = "60s"
        disruption_budget {
          percent = 100
        }
      }
    }
  }
  # Wait for all three service agent IAM bindings before creating the orchestrator.
  depends_on = [
    google_project_iam_member.osconfig,
    google_project_iam_member.osconfig_rollout,
    google_project_iam_member.progressiverollout,
  ]
}
# [END osconfig_policy_orchestrator]
