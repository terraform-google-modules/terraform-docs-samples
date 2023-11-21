/**
 * Copyright 2023 Google LLC
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


# Sample OS policy based on example - https://cloud.google.com/compute/docs/os-configuration-management/working-with-os-policies#example-2

# [START osconfig_os_policy_assignment]
resource "google_os_config_os_policy_assignment" "my_os_policy_assignment" {

  name        = "my-os-policy-assignment"
  location    = "us-west1-a"
  description = "An OS policy assignment that verifies if the Apache web server is running on CentOS VMs."

  instance_filter {
    # filter to select VMs
    all = false

    exclusion_labels {
      labels = {
        label-one = "goog-gke-node"
      }
    }

    inclusion_labels {
      labels = {
        env = "test",
      }
    }

    inventories {
      os_short_name = "centos"
      os_version    = "7.*"
    }
  }

  os_policies {
    #list of OS policies to be applied to VMs
    id   = "apache-always-up-policy"
    mode = "ENFORCEMENT"

    resource_groups { #list of resource groups for the policy
      resources {
        id = "ensure-apache-is-up"

        exec {
          validate {
            interpreter = "SHELL"
            script      = "if systemctl is-active --quiet httpd; then exit 100; else exit 101; fi"
          }

          enforce {
            interpreter = "SHELL"
            script      = "systemctl start httpd && exit 100"
          }
        }
      }

      inventory_filters {
        os_short_name = "centos"
        os_version    = "7.*"
      }
    }

    allow_no_resource_group_match = false #OS policy compliance status
    description                   = "A test OS policy"
  }

  rollout {
    #define rollout parameters
    disruption_budget {
      fixed = 1
    }
    min_wait_duration = "3.5s"
  }
}
# [END osconfig_os_policy_assignment]
