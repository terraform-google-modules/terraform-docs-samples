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

# [START gke_standard_regional_gemma_tgi]
data "google_project" "default" {
}

resource "google_container_cluster" "default" {
  name     = "gke-gemma-tgi"
  location = "us-central1"

  release_channel {
    channel = "RAPID"
  }
  initial_node_count = 1
  workload_identity_config {
    workload_pool = "${data.google_project.default.project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "default" {
  name     = "gke-gemma-tgi"
  location = "us-central1"
  node_locations = [
    "us-central1-a",
  ]
  cluster = google_container_cluster.default.id

  initial_node_count = 1
  node_config {
    machine_type = "g2-standard-8"
    guest_accelerator {
      type  = "nvidia-l4"
      count = 1
      gpu_driver_installation_config {
        gpu_driver_version = "LATEST"
      }
    }
  }
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.default.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth[0].cluster_ca_certificate)

  ignore_annotations = [
    "^cloud\\.google\\.com\\/neg"
  ]
}

resource "kubernetes_secret_v1" "default" {
  metadata {
    name = "seceret-gemma-2b-tgi"
  }

  data = {
    "hf_api_token" = "HF_TOKEN" # Replace with valid Hugging Face Token
  }
}

resource "kubernetes_deployment_v1" "default" {
  metadata {
    name = "tgi-gemma-deployment"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "gemma-server"
      }
    }

    template {
      metadata {
        labels = {
          "app"                        = "gemma-server"
          "ai.gke.io/model"            = "gemma-2-2b-it"
          "ai.gke.io/inference-server" = "text-generation-inference"
          "examples.ai.gke.io/source"  = "user-guide"
        }
      }

      spec {
        container {
          name  = "inference-server"
          image = "us-docker.pkg.dev/deeplearning-platform-release/gcr.io/huggingface-text-generation-inference-cu124.2-3.ubuntu2204.py311"

          resources {
            requests = {
              cpu                 = "2"
              memory              = "10Gi"
              "ephemeral-storage" = "10Gi"
              "nvidia.com/gpu"    = "1"
            }

            limits = {
              cpu                 = "2"
              memory              = "10Gi"
              "ephemeral-storage" = "10Gi"
              "nvidia.com/gpu"    = "1"
            }
          }

          env {
            name  = "AIP_HTTP_PORT"
            value = "8000"
          }
          env {
            name  = "NUM_SHARD"
            value = "1"
          }
          env {
            name  = "MAX_INPUT_LENGTH"
            value = "1562"
          }
          env {
            name  = "MAX_TOTAL_TOKENS"
            value = "2048"
          }
          env {
            name  = "MAX_BATCH_PREFILL_TOKENS"
            value = "2048"
          }
          env {
            name  = "CUDA_MEMORY_FRACTION"
            value = "0.93"
          }
          env {
            name  = "MODEL_ID"
            value = "google/gemma-2-2b-it"
          }
          env {
            name  = "MODEL_ID"
            value = "google/gemma-2-2b-it"
          }
          env {
            name = "HUGGING_FACE_HUB_TOKEN"
            value_from {
              secret_key_ref {
                name = kubernetes_secret_v1.default.metadata[0].name
                key  = "hf_api_token"
              }
            }
          }

          volume_mount {
            name       = "dshm"
            mount_path = "/dev/shm"
          }

        }

        volume {
          name = "dshm"
          empty_dir {
            medium = "Memory"
          }
        }

        node_selector = {
          "cloud.google.com/gke-accelerator" = "nvidia-l4"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "default" {
  metadata {
    name = "llm-service"
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.default.spec[0].selector[0].match_labels.app
    }

    port {
      protocol    = "TCP"
      port        = 8000
      target_port = 8000
    }

    type = "ClusterIP"
  }

  depends_on = [time_sleep.wait_service_cleanup]
}

# Provide time for Service cleanup
resource "time_sleep" "wait_service_cleanup" {
  depends_on = [google_container_cluster.default]

  destroy_duration = "180s"
}
# [END gke_standard_regional_gemma_tgi]

# [START gke_standard_regional_gemma_tgi_gradio]
resource "kubernetes_deployment_v1" "gradio" {
  metadata {
    name = "gradio"
    labels = {
      "app" = "gradio"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "gradio"
      }
    }
    template {
      metadata {
        labels = {
          app = "gradio"
        }
      }
      spec {
        container {
          name  = "gradio"
          image = "us-docker.pkg.dev/google-samples/containers/gke/gradio-app:v1.0.4"
          resources {
            requests = {
              cpu    = "250m"
              memory = "512Mi"
            }

            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
          }

          env {
            name  = "CONTEXT_PATH"
            value = "/generate"
          }
          env {
            name  = "HOST"
            value = "http://llm-service:8000"
          }
          env {
            name  = "LLM_ENGINE"
            value = "tgi"
          }
          env {
            name  = "MODEL_ID"
            value = "gemma"
          }
          env {
            name  = "USER_PROMPT"
            value = "<start_of_turn>user\\nprompt<end_of_turn>\\n"
          }
          env {
            name  = "SYSTEM_PROMPT"
            value = "<start_of_turn>model\\nprompt<end_of_turn>\\n"
          }
          port {
            container_port = 7860
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "gradio" {
  metadata {
    name = "gradio"
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.gradio.spec[0].selector[0].match_labels.app
    }

    port {
      protocol    = "TCP"
      port        = 8080
      target_port = 7860
    }

    type = "ClusterIP"
  }

  depends_on = [time_sleep.wait_service_cleanup]
}
# [END gke_standard_regional_gemma_tgi_gradio]
