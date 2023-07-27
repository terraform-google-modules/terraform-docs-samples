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
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# Example configuration of a Cloud Run service

# [START cloudrun_service_configuration]
resource "google_cloud_run_v2_service" "default" {
  name     = "config"
  location = "us-central1"

  # [START cloudrun_service_configuration_containers]
  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"

      # Container "entry-point" command
      command = ["/server"]

      # Container "entry-point" args
      args = []
      # [END cloudrun_service_configuration_containers]

      # [START cloudrun_service_configuration_http2]
      # Enable HTTP/2
      ports {
        name           = "h2c"
        container_port = 8080
      }
      # [END cloudrun_service_configuration_http2]

      # [START cloudrun_service_configuration_env_var]
      # Environment variables
      env {
        name  = "foo"
        value = "bar"
      }
      env {
        name  = "baz"
        value = "quux"
      }
      # [END cloudrun_service_configuration_env_var]

      # [START cloudrun_service_configuration_limit_memory]
      # [START cloudrun_service_configuration_limit_cpu]
      resources {
        limits = {
          # CPU usage limit
          cpu = "1" # 1 vCPU

          # Memory usage limit (per container)
          memory = "512Mi"
        }
        # If true, garbage-collect CPU when once a request finishes
        cpu_idle = false
      }
      # [END cloudrun_service_configuration_limit_memory]
      # [END cloudrun_service_configuration_limit_cpu]

      # [START cloudrun_service_configuration_containers]
    }
    # [END cloudrun_service_configuration_containers]

    # [START cloudrun_service_configuration_timeout]
    # Timeout
    timeout = "300s"
    # [END cloudrun_service_configuration_timeout]

    # [START cloudrun_service_configuration_concurrency]
    # Maximum concurrent requests
    max_instance_request_concurrency = 80
    # [END cloudrun_service_configuration_concurrency]

    # [START cloudrun_service_configuration_max_instances]
    # [START cloudrun_service_configuration_min_instances]
    scaling {
      # Max instances
      max_instance_count = 10

      # Min instances
      min_instance_count = 1
    }
    # [END cloudrun_service_configuration_max_instances]
    # [END cloudrun_service_configuration_min_instances]
  }

  # [START cloudrun_service_configuration_labels]
  # Labels
  labels = {
    foo : "bar"
    baz : "quux"
  }
  # [END cloudrun_service_configuration_labels]
  
  # [START cloudrun_service_configuration_containers]
}
# [END cloudrun_service_configuration_containers]
# [END cloudrun_service_configuration]
