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

# The kubernetes_manifest resource can only be used with pre-existing clusters.
# To create the cluster in advance run:
# `terraform apply -target=google_container_cluster.default`
resource "google_container_cluster" "default" {
  name     = "gke-autopilot-basic"
  location = "us-central1"

  enable_autopilot = true
}

# Required for internal ingress
resource "google_compute_subnetwork" "default" {
  name          = "proxy-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region        = google_container_cluster.default.location
  network       = "default"
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

# Required for internal ingress
resource "google_compute_address" "default" {
  name         = "hello-app-ip"
  address_type = "INTERNAL"
  region       = google_container_cluster.default.location
  purpose      = "SHARED_LOADBALANCER_VIP"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.default.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth[0].cluster_ca_certificate)
}

# [START gke_autopilot_iap_deployment]
resource "kubernetes_deployment_v1" "default" {
  metadata {
    name = "hello-app-deployment"
  }

  spec {
    selector {
      match_labels = {
        app = "hello-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "hello-app"
        }
      }

      spec {
        container {
          image = "us-docker.pkg.dev/google-samples/containers/gke/hello-app:2.0"
          name  = "hello-app-container"

          port {
            container_port = 8080
            name           = "hello-app-svc"
          }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = false

            capabilities {
              add  = []
              drop = ["NET_RAW"]
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "hello-app-svc"

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }

        security_context {
          run_as_non_root = true

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        # Toleration is currently required to prevent perpetual diff:
        # https://github.com/hashicorp/terraform-provider-kubernetes/pull/2380
        toleration {
          effect   = "NoSchedule"
          key      = "kubernetes.io/arch"
          operator = "Equal"
          value    = "amd64"
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["autopilot.gke.io/resource-adjustment"],
      metadata[0].annotations["autopilot.gke.io/warden-version"]
    ]
  }
}
# [END gke_autopilot_iap_deployment]

# [START gke_autopilot_iap_service]
resource "kubernetes_service_v1" "default" {
  metadata {
    name = "hello-app-service"
    annotations = {
      "cloud.google.com/backend-config" = "{\"ports\": {\"80\":\"${kubernetes_manifest.backendconfig.manifest.metadata.name}\"}}"
      "cloud.google.com/neg"            = "{\"ingress\": true}"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = kubernetes_deployment_v1.default.spec[0].selector[0].match_labels.app
    }

    port {
      port        = 80
      protocol    = kubernetes_deployment_v1.default.spec[0].template[0].spec[0].container[0].port[0].protocol
      target_port = kubernetes_deployment_v1.default.spec[0].template[0].spec[0].container[0].port[0].container_port
    }
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations["cloud.google.com/neg-status"]
    ]
  }

  depends_on = [time_sleep.wait_service_cleanup]
}
# [END gke_autopilot_iap_service]

# [START gke_autopilot_iap_ingress]
resource "kubernetes_ingress_v1" "default" {
  metadata {
    name = "hello-app-ingress"
    annotations = {
      "kubernetes.io/ingress.class"                   = "gce-internal" # Remove to create an external
      "ingress.gcp.kubernetes.io/pre-shared-cert"     = google_compute_region_ssl_certificate.default.name
      "kubernetes.io/ingress.regional-static-ip-name" = google_compute_address.default.name
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service_v1.default.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    time_sleep.wait_service_cleanup,
    google_compute_subnetwork.default,
    google_compute_region_ssl_certificate.default
  ]
}
# [END gke_autopilot_iap_ingress]

# [START gke_autopilot_iap_backendconfig]
resource "kubernetes_manifest" "backendconfig" {
  manifest = {
    apiVersion = "cloud.google.com/v1"
    kind       = "BackendConfig"

    metadata = {
      name      = "backendconfig"
      namespace = "default"
    }

    spec = {
      iap = {
        enabled = true
      }
      timeoutSec = 40
      connectionDraining = {
        drainingTimeoutSec = 60
      }
    }
  }

  depends_on = [time_sleep.wait_service_cleanup]
}
# [END gke_autopilot_iap_backendconfig]

# self-signed cert for internal ingress
resource "google_compute_region_ssl_certificate" "default" {
  name_prefix = "iap-certificate-"
  private_key = tls_private_key.default.private_key_pem
  certificate = tls_self_signed_cert.default.cert_pem
  region      = google_container_cluster.default.location
  lifecycle {
    create_before_destroy = true
  }
}

resource "tls_private_key" "default" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "default" {
  private_key_pem = tls_private_key.default.private_key_pem

  validity_period_hours = 12
  early_renewal_hours   = 3

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["localhost"]

  subject {
    common_name  = "localhost"
    organization = "terrraform-docs-samples"
  }
}

# Provide time for service cleanup
resource "time_sleep" "wait_service_cleanup" {
  depends_on = [google_container_cluster.default]

  destroy_duration = "180s"
}
