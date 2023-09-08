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

# [START looker_google_looker_instance_enterprise_full]
# Creates an Enterprise edition Looker (Google Cloud core) instance with full, Private IP functionality.
resource "google_looker_instance" "main" {
  name               = "my-instance"
  platform_edition   = "LOOKER_CORE_ENTERPRISE_ANNUAL"
  region             = "us-central1"
  private_ip_enabled = true
  public_ip_enabled  = false
  reserved_range     = google_compute_global_address.main.name
  consumer_network   = data.google_compute_network.main.id
  admin_settings {
    allowed_email_domains = ["google.com"]
  }
  encryption_config {
    kms_key_name = google_kms_crypto_key.main.id
  }
  maintenance_window {
    day_of_week = "THURSDAY"
    start_time {
      hours   = 22
      minutes = 0
      seconds = 0
      nanos   = 0
    }
  }
  deny_maintenance_period {
    start_date {
      year  = 2050
      month = 1
      day   = 1
    }
    end_date {
      year  = 2050
      month = 2
      day   = 1
    }
    time {
      hours   = 10
      minutes = 0
      seconds = 0
      nanos   = 0
    }
  }
  oauth_config {
    client_id     = "my-client-id"
    client_secret = "my-client-secret"
  }
  depends_on = [
    google_service_networking_connection.main,
    google_kms_crypto_key.main
  ]
}

resource "google_kms_key_ring" "main" {
  name     = "keyring-example"
  location = "us-central1"
}

resource "google_kms_crypto_key" "main" {
  name     = "crypto-key-example"
  key_ring = google_kms_key_ring.main.id
}

resource "google_service_networking_connection" "main" {
  network                 = data.google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.main.name]
}

resource "google_compute_global_address" "main" {
  name          = "looker-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 20
  network       = data.google_compute_network.main.id
}

data "google_project" "main" {}

data "google_compute_network" "main" {
  name = "default"
}

resource "google_kms_crypto_key_iam_member" "main" {
  crypto_key_id = google_kms_crypto_key.main.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.main.number}@gcp-sa-looker.iam.gserviceaccount.com"
}
# [END looker_google_looker_instance_enterprise_full]
