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

# [START gke_quickstart_autopilot_app]
# Retrieve the access token for configuring the Kubernetes provider
data "google_client_config" "default" {}

# Retrieve the cluster details for configuring the Kubernetes provider
data "google_container_cluster" "default" {
  name     = "example-autopilot-cluster"
  location = "us-central1"
}

provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.default.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.default.master_auth[0].cluster_ca_certificate)
}

resource "kubernetes_deployment_v1" "default" {
  metadata {
    name = "example-hello-app-deployment"
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
        }
      }
    }
  }
}

# Expose the hello-app using a loadblancer
resource "kubernetes_service_v1" "default" {
  metadata {
    name = "example-hello-app-loadbalancer"
    annotations = {
      "cloud.google.com/load-balancer-type" = "Internal" # Remove to create an external loadbalance
    }
  }

  spec {
    selector = {
      app = kubernetes_deployment_v1.default.spec[0].selector[0].match_labels.app
    }

    ip_family_policy = "RequireDualStack"

    port {
      port        = 80
      target_port = kubernetes_deployment_v1.default.spec[0].template[0].spec[0].container[0].port[0].name
    }

    type = "LoadBalancer"
  }
}
# [END gke_quickstart_autopilot_app]
