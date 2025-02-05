/**
* Copyright 2025 Google LLC
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

# [START gke_standard_regional_node_system_config]
resource "google_container_cluster" "default" {
  name     = "gke-standard-regional-cluster"
  location = "us-central1"

  initial_node_count = 1

  node_config {
    # Kubelet configuration
    kubelet_config {
      cpu_manager_policy = "static"
    }

    linux_node_config {
      # Sysctl configuration
      sysctls = {
        "net.core.netdev_max_backlog" = "10000"
      }

      # Linux cgroup mode configuration
      cgroup_mode = "CGROUP_MODE_V2"

      # Linux huge page configuration
      hugepages_config {
        hugepage_size_2m = "1024"
      }
    }
  }

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}
# [END gke_standard_regional_node_system_config]

# [START gke_standard_regional_node_system_config_node_pool]
resource "google_container_node_pool" "default" {
  name    = "gke-standard-regional-node-pool"
  cluster = google_container_cluster.default.name

  node_config {
    # Kubelet configuration
    kubelet_config {
      cpu_manager_policy = "static"
    }

    linux_node_config {
      # Sysctl configuration
      sysctls = {
        "net.core.netdev_max_backlog" = "10000"
      }

      # Linux cgroup mode configuration
      cgroup_mode = "CGROUP_MODE_V2"

      # Linux huge page configuration
      hugepages_config {
        hugepage_size_2m = "1024"
      }
    }
  }
}
# [END gke_standard_regional_node_system_config_node_pool]
