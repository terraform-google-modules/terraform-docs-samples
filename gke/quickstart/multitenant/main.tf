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

# [START gke_quickstart_multitenant]
data "google_project" "default" {}
# [START gke_quickstart_multitenant_teams]
locals {
  teams = toset([
    "frontend",
    "backend",
  ])
}

// Creates team specific service accounts which can be used to apply app manifests:
// gcloud config set auth/impersonate_service_account ${TEAM}@${PROJECT_ID}.iam.gserviceaccount.com
// gcloud container fleet memberships get-credentials gke-enterprise-cluster --location us-central1 --project ${PROJECT_ID}
// kubectl apply -f {TEAM}.yaml
resource "google_service_account" "default" {
  for_each = local.teams

  project                      = data.google_project.default.project_id
  account_id                   = each.key
  display_name                 = each.key
  create_ignore_already_exists = true
}

resource "google_project_iam_member" "viewer" {
  for_each = google_service_account.default

  project = data.google_project.default.project_id
  role    = "roles/gkehub.viewer"
  member  = "serviceAccount:${each.value.email}"
}

resource "google_project_iam_member" "gatewayeditor" {
  for_each = google_service_account.default

  project = data.google_project.default.project_id
  role    = "roles/gkehub.gatewayEditor"
  member  = "serviceAccount:${each.value.email}"
}
# [END gke_quickstart_multitenant_teams]
# [START gke_quickstart_multitenant_fleet]
resource "google_gke_hub_feature" "policycontroller" {
  name     = "policycontroller"
  location = "global"
  project  = data.google_project.default.project_id

  fleet_default_member_config {
    policycontroller {
      policy_controller_hub_config {
        install_spec = "INSTALL_SPEC_ENABLED"
        policy_content {
          bundles {
            bundle = "pss-baseline-v2022"
          }
          template_library {
            installation = "ALL"
          }
        }
      }
    }
  }
}

resource "google_gke_hub_scope" "default" {
  for_each = local.teams

  project  = data.google_project.default.project_id
  scope_id = "${each.key}-team"
}

resource "google_gke_hub_namespace" "default" {
  for_each = local.teams

  scope_namespace_id = google_gke_hub_scope.default[each.key].scope_id
  scope_id           = google_gke_hub_scope.default[each.key].scope_id
  scope              = google_gke_hub_scope.default[each.key].name
  project            = data.google_project.default.project_id
}
# [END gke_quickstart_multitenant_fleet]
# [START gke_quickstart_multitenant_cluster]
resource "google_container_cluster" "default" {
  name               = "gke-enterprise-cluster"
  location           = "us-central1"
  initial_node_count = 3
  fleet {
    project = data.google_project.default.project_id
  }
  workload_identity_config {
    workload_pool = "${data.google_project.default.project_id}.svc.id.goog"
  }
  security_posture_config {
    mode               = "BASIC"
    vulnerability_mode = "VULNERABILITY_ENTERPRISE"
  }
  depends_on = [
    google_gke_hub_feature.policycontroller,
    google_gke_hub_namespace.default
  ]
  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}

resource "google_gke_hub_membership_binding" "default" {
  for_each = google_gke_hub_scope.default

  project               = data.google_project.default.project_id
  membership_binding_id = each.value.scope_id
  scope                 = each.value.name
  membership_id         = google_container_cluster.default.fleet[0].membership_id
  location              = google_container_cluster.default.fleet[0].membership_location
}
# [END gke_quickstart_multitenant_cluster]
# [START gke_quickstart_multitenant_rbac]
resource "google_gke_hub_scope_rbac_role_binding" "default" {
  for_each = local.teams

  project                    = data.google_project.default.project_id
  scope_rbac_role_binding_id = each.key
  scope_id                   = google_gke_hub_scope.default[each.key].scope_id
  user                       = google_service_account.default[each.key].email
  role {
    predefined_role = "EDIT"
  }
  depends_on = [google_gke_hub_scope.default]
}
# [END gke_quickstart_multitenant_rbac]
# [START gke_quickstart_multitenant_database]
// Create Database for Apps
resource "google_sql_database" "database" {
  name     = "multitenant-app"
  project  = data.google_project.default.project_id
  instance = google_sql_database_instance.default.name
}

resource "google_sql_database_instance" "default" {
  name             = "gkee-multitenant-app-db"
  project          = data.google_project.default.project_id
  region           = "us-central1"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}

resource "google_sql_user" "users" {
  name     = "multitenant-app"
  project  = data.google_project.default.project_id
  instance = google_sql_database_instance.default.name
  host     = "cloudsqlproxy~%"
  password = ""
}

resource "google_project_iam_member" "cloudsql" {
  for_each = local.teams

  project = data.google_project.default.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${data.google_project.default.project_id}.svc.id.goog[${each.value}-team/default]"

  depends_on = [google_container_cluster.default]
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${google_container_cluster.default.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.default.master_auth[0].cluster_ca_certificate)
}

// Store Database instance name in team config maps
resource "kubernetes_config_map" "default" {
  for_each = local.teams

  metadata {
    name      = "database-configmap"
    namespace = "${each.key}-team"
  }

  data = {
    CONNECTION_NAME = google_sql_database_instance.default.connection_name
  }
}
# [END gke_quickstart_multitenant_database]
# [END gke_quickstart_multitenant]
