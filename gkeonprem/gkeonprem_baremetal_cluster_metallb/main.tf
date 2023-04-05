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

#[START gkeonprem_bare_metal_cluster_metallb]

# GCP project information is fetched from the 'GOOGLE_CLOUD_PROJECT' environment
# variable if it is not explicitely set in this data block.
data "google_project" "project" {
  project_id = "YOUR_PROJECT_ID"
}

# Fill in the local variables according to your baremetal environment; you must
# already have an admin cluster created according to the prerequisites outlined
# in https://cloud.google.com/anthos/clusters/docs/bare-metal/latest/installing/creating-clusters/create-user-cluster-api#before_you_begin
locals {
  admin_cluster     = "YOUR_ADMIN_CLUSTER_NAME"
  bmctl_version     = "BMCTL_VERSION"
  control_plane_ip  = "IP_ADDRESS_OF_NEW_CLUSTER_CONTROL_PLANE_NODE" # 10.200.0.4
  control_plane_vip = "LB_VIRTUAL_IP_ADDRESS_FOR_CONTROL_PLANE_API"  # 10.200.0.50
  ingress_vip       = "LB_VIRTUAL_IP_ADDRESS_FOR_INGRESS_GATEWAY"    # 10.200.0.51
  lb_address_pool_1 = "ADDRESS_POOL_FOR_USE_BY_LB"                   # 10.200.0.51-10.200.0.70
  admin_user_emails = ["ADMIN_1_GCP_ACCOUNT", "ADMIN_2_GCP_ACCOUNT"] # [foo@gmail.com, bar@gmail.com]
  worker_node_ips   = ["WORKER_NODE_1_IP", "WORKER_NODE_2_IP"]       # [10.200.0.5, 10.200.0.6]
  region            = "us-west1"
  endpoint          = "https://gkeonprem.googleapis.com/v1/"
}

provider "google-private" {
  project                   = data.google_project.project.project_id
  region                    = local.region
  gkeonprem_custom_endpoint = local.endpoint
}

# Enable GKE OnPrem API
resource "google_project_service" "default" {
  project            = data.google_project.project.project_id
  service            = "gkeonprem.googleapis.com"
  disable_on_destroy = false
}

# Create an anthos baremetal user cluster and enroll it with the gkeonprem API
resource "google_gkeonprem_bare_metal_cluster" "default" {
  name                     = "gkeonprem-bm-cluster-metallb"
  description              = "Anthos bare metal user cluster with MetalLB"
  provider                 = google-private
  depends_on               = [google_project_service.default]
  location                 = local.region
  bare_metal_version       = local.bmctl_version
  admin_cluster_membership = "projects/${data.google_project.project.project_id}/locations/global/memberships/${local.admin_cluster}"
  network_config {
    island_mode_cidr {
      service_address_cidr_blocks = ["172.26.0.0/16"]
      pod_address_cidr_blocks     = ["10.240.0.0/13"]
    }
  }
  control_plane {
    control_plane_node_pool_config {
      node_pool_config {
        operating_system = "LINUX"
        node_configs {
          node_ip = local.control_plane_ip
        }
      }
    }
  }
  load_balancer {
    port_config {
      control_plane_load_balancer_port = 443
    }
    vip_config {
      control_plane_vip = local.control_plane_vip
      ingress_vip       = local.ingress_vip
    }
    metal_lb_config {
      address_pools {
        pool = "pool1"
        addresses = [
          local.lb_address_pool_1
        ]
      }
    }
  }
  storage {
    lvp_share_config {
      lvp_config {
        path          = "/mnt/localpv-share"
        storage_class = "local-shared"
      }
      shared_path_pv_count = 5
    }
    lvp_node_mounts_config {
      path          = "/mnt/localpv-disk"
      storage_class = "local-disks"
    }
  }

  security_config {
    authorization {
      dynamic "admin_users" {
        for_each = local.admin_user_emails
        content {
          username = admin_users.value
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      annotations["onprem.cluster.gke.io/user-cluster-resource-link"],
      annotations["alpha.baremetal.cluster.gke.io/cluster-metrics-webhook"],
      annotations["baremetal.cluster.gke.io/operation"],
      annotations["baremetal.cluster.gke.io/operation-id"],
      annotations["baremetal.cluster.gke.io/start-time"],
      annotations["baremetal.cluster.gke.io/upgrade-from-version"]
    ]
  }
}

# Create a node pool of worker nodes for the anthos baremetal user cluster
resource "google_gkeonprem_bare_metal_node_pool" "default" {
  name               = "node-pool1"
  display_name       = "Nodepool 1"
  provider           = google-private
  bare_metal_cluster = google_gkeonprem_bare_metal_cluster.default.name
  location           = local.region
  node_pool_config {
    operating_system = "LINUX"
    labels           = {}

    dynamic "node_configs" {
      for_each = local.worker_node_ips
      content {
        labels  = {}
        node_ip = node_configs.value
      }
    }
  }

  lifecycle {
    ignore_changes = [
      annotations["baremetal.cluster.gke.io/gke-version"],
      annotations["baremetal.cluster.gke.io/version"],
    ]
  }
}
#[END gkeonprem_bare_metal_cluster_metallb]
