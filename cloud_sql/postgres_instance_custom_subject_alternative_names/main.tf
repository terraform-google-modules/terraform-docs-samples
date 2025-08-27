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
# [START cloud_sql_postgres_instance_custom_subject_alternative_names_create]
# [START cloud_sql_postgres_instance_service_identity]
resource "google_project_service_identity" "default" {
  provider = google-beta
  service  = "sqladmin.googleapis.com"
}
# [END cloud_sql_postgres_instance_service_identity]

# [START cloud_sql_postgres_privateca_ca_pool_suffix]
resource "random_string" "default" {
  length  = 10
  special = false
  upper   = false
}
# [END cloud_sql_postgres_privateca_ca_pool_suffix]

# [START cloud_sql_postgres_instance_ca_pool]
resource "google_privateca_ca_pool" "default" {
  name     = "customer-ca-pool-${random_string.default.result}"
  location = "asia-northeast1"
  tier     = "DEVOPS"
  publishing_options {
    publish_ca_cert = false
    publish_crl     = false
  }
}
# [END cloud_sql_postgres_instance_ca_pool]

# [START cloud_sql_postgres_instance_ca]
# This is required for setting up customer managed CAS (Certificate Authority Service) instances.
resource "google_privateca_certificate_authority" "default" {
  pool                                   = google_privateca_ca_pool.default.name
  certificate_authority_id               = "my-certificate-authority"
  location                               = "asia-northeast1"
  lifetime                               = "86400s"
  type                                   = "SELF_SIGNED"
  deletion_protection                    = false # set to "true" in production
  skip_grace_period                      = true
  ignore_active_certificates_on_deletion = true
  config {
    subject_config {
      subject {
        organization = "my organization"
        common_name  = "my certificate authority name"
      }
    }
    x509_config {
      ca_options {
        is_ca = true
      }
      key_usage {
        base_key_usage {
          cert_sign = true
          crl_sign  = true
        }
        extended_key_usage {
          server_auth = false
        }
      }
    }
  }
  key_spec {
    algorithm = "RSA_PKCS1_4096_SHA256"
  }
}
# [END cloud_sql_postgres_instance_ca]

# [START cloud_sql_postgres_instance_iam_granting]
resource "google_privateca_ca_pool_iam_member" "default" {
  ca_pool = google_privateca_ca_pool.default.id
  role    = "roles/privateca.certificateRequester"

  member = "serviceAccount:${google_project_service_identity.default.email}"
}
# [END cloud_sql_postgres_instance_iam_granting]

# [START cloud_sql_postgres_instance_custom_subject_alternative_names]
resource "google_sql_database_instance" "default" {
  name             = "postgres-instance"
  region           = "asia-northeast1"
  database_version = "POSTGRES_17"
  settings {
    edition = "ENTERPRISE"
    tier    = "db-f1-micro"
    ip_configuration {
      # The following server CA mode lets the instance use customer-managed CAS CA to issue server certificates.
      # https://cloud.google.com/sql/docs/postgres/admin-api/rest/v1beta4/instances#ipconfiguration
      server_ca_mode                   = "CUSTOMER_MANAGED_CAS_CA"
      server_ca_pool                   = google_privateca_ca_pool.default.id
      custom_subject_alternative_names = ["customSan.test.com"]
    }
  }
}
# [END cloud_sql_postgres_instance_custom_subject_alternative_names]
# [END cloud_sql_postgres_instance_custom_subject_alternative_names_create]