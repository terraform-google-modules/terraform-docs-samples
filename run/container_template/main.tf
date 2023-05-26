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

# [START cloudrun_container_template_parent_tag]
# [START cloudrun_service_configuration]
resource "google_cloud_run_service" "default" {
  name     = "config"
  location = "us-central1"

  # [START cloudrun_service_configuration_containers]
  template {
    spec {
      containers {
        image = "us-docker.pkg.dev/cloudrun/container/hello"

        # Container "entry-point" command
        # https://cloud.google.com/run/docs/configuring/containers#configure-entrypoint
        command = ["/server"]

        # Container "entry-point" args
        # https://cloud.google.com/run/docs/configuring/containers#configure-entrypoint
        args = []
        # [END cloudrun_service_configuration_containers]

        # [START cloudrun_service_configuration_http2]
        # Enable HTTP/2
        # https://cloud.google.com/run/docs/configuring/http2
        ports {
          name           = "h2c"
          container_port = 8080
        }
        # [END cloudrun_service_configuration_http2]

        # [START cloudrun_service_configuration_env_var]
        # Environment variables
        # https://cloud.google.com/run/docs/configuring/environment-variables
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
            # https://cloud.google.com/run/docs/configuring/cpu
            cpu = "1000m" # 1 vCPU

            # Memory usage limit (per container)
            # https://cloud.google.com/run/docs/configuring/memory-limits
            memory = "512Mi"
          }
        }
        # [END cloudrun_service_configuration_limit_memory]
        # [END cloudrun_service_configuration_limit_cpu]

        # [START cloudrun_service_configuration_containers]
      }
      # [END cloudrun_service_configuration_containers]

      # [START cloudrun_service_configuration_timeout]
      # Timeout
      # https://cloud.google.com/run/docs/configuring/request-timeout
      timeout_seconds = 300
      # [END cloudrun_service_configuration_timeout]

      # [START cloudrun_service_configuration_concurrency]
      # Maximum concurrent requests
      # https://cloud.google.com/run/docs/configuring/concurrency
      container_concurrency = 80
      # [END cloudrun_service_configuration_concurrency]

      # [START cloudrun_service_configuration_containers]
    }
    # [END cloudrun_service_configuration_containers]

    # [START cloudrun_service_configuration_max_instances]
    # [START cloudrun_service_configuration_min_instances]
    # [START cloudrun_service_configuration_labels]
    metadata {
      # [END cloudrun_service_configuration_labels]
      annotations = {

        # Max instances
        # https://cloud.google.com/run/docs/configuring/max-instances
        "autoscaling.knative.dev/maxScale" = 10

        # Min instances
        # https://cloud.google.com/run/docs/configuring/min-instances
        "autoscaling.knative.dev/minScale" = 1

        # If true, garbage-collect CPU when once a request finishes
        # https://cloud.google.com/run/docs/configuring/cpu-allocation
        "run.googleapis.com/cpu-throttling" = false
      }
      # [END cloudrun_service_configuration_max_instances]
      # [END cloudrun_service_configuration_min_instances]

      # [START cloudrun_service_configuration_labels]
      # Labels
      # https://cloud.google.com/run/docs/configuring/labels
      labels = {
        foo : "bar"
        baz : "quux"
      }
      # [START cloudrun_service_configuration_max_instances]
      # [START cloudrun_service_configuration_min_instances]
    }
    # [END cloudrun_service_configuration_labels]
    # [END cloudrun_service_configuration_max_instances]
    # [END cloudrun_service_configuration_min_instances]
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
# [END cloudrun_service_configuration]
# [END cloudrun_container_template_parent_tag]