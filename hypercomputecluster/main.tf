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

# [START hypercomputecluster_v1_clusterservice_cluster_create]

resource "google_hypercomputecluster_cluster" "default" {
  cluster_id = "cluster001"
  location   = "europe-west1"

  network_resources {
    id = "cnet"
    config {
      new_network {
        network = "projects/my-project/global/networks/new-network"
      }
    }
  }

  compute_resources {
    id = "comp1"
    config {
      new_reserved_instances {
        reservation = "projects/my-project/zones/europe-west1-b/reservations/example-reservation"
      }
    }
  }

  compute_resources {
    id = "comp2"
    config {
      new_spot_instances {
        machine_type = "n2-standard-4"
        zone         = "europe-west1-b"
      }
    }
  }


  orchestrator {
    slurm {
      default_partition = "part1"
      login_nodes {
        count             = "1"
        enable_os_login   = true
        enable_public_ips = true
        machine_type      = "n2-standard-4"
        zone              = "europe-west1-b"
      }

      node_sets {
        id                = "nodeset1"
        compute_id        = "comp1"
        static_node_count = "1"
        compute_instance {
          boot_disk {
            size_gb = "100"
            type    = "pd-balanced"
          }
        }
        storage_configs {
          id          = "fs1"
          local_mount = "/home"
        }
      }

      node_sets {
        id                = "nodeset2"
        compute_id        = "comp2"
        static_node_count = "1"
        compute_instance {
          boot_disk {
            size_gb = "100"
            type    = "pd-balanced"
          }
        }
        storage_configs {
          id          = "fs1"
          local_mount = "/home"
        }
      }

      partitions {
        id           = "part1"
        node_set_ids = ["nodeset1"]
      }
      partitions {
        id           = "part2"
        node_set_ids = ["nodeset2"]
      }
    }
  }

  storage_resources {
    id = "fs1"
    config {
      new_filestore {
        filestore = "projects/my-project/locations/europe-west1-b/instances/filestore-instance-example"
        protocol  = "NFSV3"
        tier      = "ZONAL"
        file_shares {
          capacity_gb = "1024"
          file_share  = "nfsshare"
        }
      }
    }
  }
}

# [END hypercomputecluster_v1_clusterservice_cluster_create]
