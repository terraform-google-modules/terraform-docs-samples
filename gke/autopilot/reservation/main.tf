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

data "google_client_config" "default" {}

resource "google_container_cluster" "default" {
  name     = "gke-autopilot-cluster"
  location = "us-central1"

  enable_autopilot = true

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}

# [START gke_autopilot_reservation_specific]
resource "google_compute_reservation" "specific_pod" {
  name = "specific-reservation-pod"
  zone = "us-central1-a"

  specific_reservation {
    count = 1

    instance_properties {
      machine_type = "c3-standard-4-lssd"

      local_ssds {
        disk_size_gb = 375
        interface    = "NVME"
      }
    }
  }

  specific_reservation_required = true
}
# [END gke_autopilot_reservation_specific]

# [START gke_autopilot_reservation_specific]
resource "google_compute_reservation" "specific_accelerator" {
  name = "specific-reservation-accelerator"
  zone = "us-central1-a"

  specific_reservation {
    count = 1

    instance_properties {
      #min_cpu_platform = "Intel Cascade Lake"
      machine_type = "g2-standard-4"

      guest_accelerators {
        accelerator_count = 1
        accelerator_type  = "nvidia-l4"
      }
    }
  }

  specific_reservation_required = true
}
# [END gke_autopilot_reservation_specific]

provider "kubernetes" {
  host                   = "https://${google_container_cluster.default.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth[0].cluster_ca_certificate)

  ignore_annotations = [
    "^autopilot\\.gke\\.io\\/.*",
    "^cloud\\.google\\.com\\/cluster_autoscaler_.*"
  ]
}

# [START gke_autopilot_reservation_specific_pod]
resource "kubernetes_pod_v1" "default_pod" {
  metadata {
    name = "specific-same-project-pod"
  }

  spec {
    node_selector = {
      "cloud.google.com/compute-class"        = "Performance"
      "cloud.google.com/machine-family"       = "c3"
      "cloud.google.com/reservation-name"     = google_compute_reservation.specific_pod.name
      "cloud.google.com/reservation-affinity" = "specific"
    }

    container {
      name  = "my-container"
      image = "k8s.gcr.io/pause"

      resources {
        requests = {
          cpu               = 2
          memory            = "8Gi"
          ephemeral-storage = "1Gi"
        }
      }

      security_context {
        allow_privilege_escalation = false
        run_as_non_root            = false

        capabilities {
          add  = []
          drop = ["NET_RAW"]
        }
      }
    }

    security_context {
      run_as_non_root     = false
      supplemental_groups = []

      seccomp_profile {
        type = "RuntimeDefault"
      }
    }
  }

  depends_on = [
    google_compute_reservation.specific_pod
  ]
}
# [END gke_autopilot_reservation_specific_pod]

# [START gke_autopilot_reservation_specific_accelerator]
resource "kubernetes_pod_v1" "default_accelerator" {
  metadata {
    name = "specific-same-project-accelerator"
  }

  spec {
    node_selector = {
      "cloud.google.com/compute-class"        = "Accelerator"
      "cloud.google.com/gke-accelerator"      = "nvidia-l4"
      "cloud.google.com/reservation-name"     = google_compute_reservation.specific_accelerator.name
      "cloud.google.com/reservation-affinity" = "specific"
    }

    container {
      name  = "my-container"
      image = "k8s.gcr.io/pause"

      resources {
        requests = {
          cpu               = 2
          memory            = "7Gi"
          ephemeral-storage = "1Gi"
          "nvidia.com/gpu"  = 1

        }
        limits = {
          "nvidia.com/gpu" = 1
        }
      }

      security_context {
        allow_privilege_escalation = false
        run_as_non_root            = false

        capabilities {
          add  = []
          drop = ["NET_RAW"]
        }
      }
    }

    security_context {
      run_as_non_root     = false
      supplemental_groups = []

      seccomp_profile {
        type = "RuntimeDefault"
      }
    }
  }

  depends_on = [
    google_compute_reservation.specific_accelerator
  ]
}
# [END gke_autopilot_reservation_specific_accelerator]
