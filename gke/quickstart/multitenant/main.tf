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
locals {
  teams = toset([
    "frontend",
    "backend",
  ])
}

data "google_project" "default" {}

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
# [START gke_quickstart_multitenant_fleet]
# resource "google_gke_hub_feature" "policycontroller" {
#   name     = "policycontroller"
#   location = "global"
#   project  = data.google_project.default.project_id

#   fleet_default_member_config {
#     policycontroller {
#       policy_controller_hub_config {
#         install_spec = "INSTALL_SPEC_ENABLED"
#         policy_content {
#           bundles {
#             bundle = "pss-baseline-v2022"
#           }
#           template_library {
#             installation = "ALL"
#           }
#         }
#       }
#     }
#   }
# }

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
    #google_gke_hub_feature.policycontroller,
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

module "gcloud" {
  source  = "terraform-google-modules/gcloud/google//modules/kubectl-fleet-wrapper"
  version = "~> 3.4"

  for_each = local.teams

  # Uncomment to enable the apps using the respective team's service accounts
  # impersonate_service_account = google_service_account.default[each.value].email

  membership_name       = google_container_cluster.default.fleet[0].membership_id
  membership_project_id = data.google_project.default.project_id
  membership_location   = google_container_cluster.default.fleet[0].membership_location

  kubectl_create_command  = "kubectl apply -f ${each.value}.yaml"
  kubectl_destroy_command = "kubectl delete -f ${each.value}.yaml"

  create_cmd_triggers = {
    policy_sha1 = sha1(file("${each.value}.yaml"))
  }
}
# [END gke_quickstart_multitenant]
