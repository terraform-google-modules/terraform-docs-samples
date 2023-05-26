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

# [START compute_os_login_parent_tag]
# [START compute_terraform-oslogin-example]

# [START compute_enable_oslogin_api]
resource "google_project_service" "project" {
  service            = "oslogin.googleapis.com"
  disable_on_destroy = false
}
# [END compute_enable_oslogin_api]

# [START compute_project_for_oslogin_example]
resource "google_compute_project_metadata" "default" {
  metadata = {
    enable-oslogin = "TRUE"
  }
}
# [END compute_project_for_oslogin_example]

# [START compute_instance_for_oslogin_example]
resource "google_compute_instance" "oslogin_instance" {
  name         = "oslogin-instance-name"
  machine_type = "f1-micro"
  zone         = "us-central1-c"
  metadata = {
    enable-oslogin : "TRUE"
  }
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
}
# [END compute_instance_for_oslogin_example]


# [START compute_add_iam_binding_for_oslogin]
data "google_project" "project" {
}
resource "google_project_iam_member" "os_login_admin_users" {
  project = data.google_project.project.project_id
  role    = "roles/compute.osAdminLogin"
  member  = "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com"
}
# [END compute_add_iam_binding_for_oslogin]

# [END compute_terraform-oslogin-example]
# [END compute_os_login_parent_tag]