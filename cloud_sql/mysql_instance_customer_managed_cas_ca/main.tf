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
# [START cloud_sql_instance_service_identity]
resource "google_project_service_identity" "gcp_sa_cloud_sql" {
  provider = google-beta
  service  = "sqladmin.googleapis.com"
}
# [END cloud_sql_instance_service_identity]

# [START cloud_sql_mysql_instance_ca_pool]
resource "google_privateca_ca_pool" "customer_ca_pool" {
  name     = "tf-test-cap"
  location = "asia-northeast1"
  tier     = "DEVOPS"
  publishing_options {
    publish_ca_cert = false
    publish_crl     = false
  }
}
# [END cloud_sql_mysql_instance_ca_pool]

# [START cloud_sql_mysql_instance_ca]
resource "google_privateca_certificate_authority" "customer_ca" {
  pool                                   = google_privateca_ca_pool.customer_ca_pool.name
  certificate_authority_id               = "tf-test-ca"
  location                               = "asia-northeast1"
  lifetime                               = "86400s"
  type                                   = "SELF_SIGNED"
  deletion_protection                    = false
  skip_grace_period                      = true
  ignore_active_certificates_on_deletion = true
  config {
    subject_config {
      subject {
        organization = "Test LLC"
        common_name  = "my-ca"
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
# [END cloud_sql_mysql_instance_ca]

# [START cloud_sql_mysql_instance_iam_granting]
resource "google_privateca_ca_pool_iam_member" "granting" {
  ca_pool = google_privateca_ca_pool.customer_ca_pool.id
  role    = "roles/privateca.certificateRequester"

  member = "serviceAccount:${google_project_service_identity.gcp_sa_cloud_sql.email}"
}
# [END cloud_sql_mysql_instance_iam_granting]

# [START cloud_sql_mysql_instance_customer_managed_cas_ca]
resource "google_sql_database_instance" "mysql_instance" {
  name             = "mysql-instance"
  region           = "asia-northeast1"
  database_version = "MYSQL_8_0"
  settings {
    tier = "db-f1-micro"
    ip_configuration {
      # The following server CA mode lets the instance use customer-managed CAS CA to issue server certificates.
      # https://cloud.google.com/sql/docs/mysql/admin-api/rest/v1beta4/instances#ipconfiguration
      server_ca_mode = "CUSTOMER_MANAGED_CAS_CA"
      # This is the name of the customer-owned CAS CA pool.
      server_ca_pool = google_privateca_ca_pool.customer_ca_pool.id
    }
  }
  # set `deletion_protection` to true, will ensure that one cannot accidentally delete this instance by
  # use of Terraform whereas `deletion_protection_enabled` flag protects this instance at the GCP level.
  deletion_protection = false
}
# [END cloud_sql_mysql_instance_customer_managed_cas_ca]
