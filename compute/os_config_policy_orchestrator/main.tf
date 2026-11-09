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
        # Specify project numbers prefixed with "projects/".
        included_projects = ["projects/123456789012"]
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
      description = "Verify that the example configuration file is present on Debian VMs."

      os_policies {
        id   = "example-os-policy"
        mode = "VALIDATION"

        resource_groups {
          resources {
            id = "example-file-resource"

            file {
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
}
# [END osconfig_policy_orchestrator]
EOF
