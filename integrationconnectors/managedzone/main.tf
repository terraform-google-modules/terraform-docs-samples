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

# This is the target project where you host the cloud DNS mapping, this can also be the current project
data "google_project" "target_project" {
}

resource "google_project_iam_member" "default" {
  project = data.google_project.target_project.project_id
  role    = "roles/dns.peer"
  member  = "serviceAccount:service-${data.google_project.test_project.number}@gcp-sa-connectors.iam.gserviceaccount.com"
}

resource "google_compute_network" "default" {
  project                 = data.google_project.target_project.project_id
  name                    = "test"
  auto_create_subnetworks = false
}

resource "google_dns_managed_zone" "default" {
  name       = "test-dns"
  dns_name   = "private.example.com."
  visibility = "private"

  private_visibility_config {
    networks {
      network_url = google_compute_network.default.id
    }
  }
}

# This is the current project.
data "google_project" "test_project" {
}

# [START integrationconnectors_managed_zone_example]
resource "google_integration_connectors_managed_zone" "test_managed_zone" {
  name        = "test-managed-zone"
  description = "tf created resource"
  labels = {
    intent = "example"
  }
  target_project = data.google_project.target_project.project_id
  target_vpc     = "test"
  dns            = google_dns_managed_zone.default.dns_name
  depends_on     = [google_project_iam_member.default]
}
# [END integrationconnectors_managed_zone_example]
