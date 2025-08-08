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

# [START privateca_quickstart]
provider "google" {}
provider "tls" {}

resource "google_project_service" "privateca_api" {
  service            = "privateca.googleapis.com"
  disable_on_destroy = false
}

# Root CaPool & CA

resource "google_privateca_ca_pool" "root" {
  name     = "root-pool"
  location = "us-central1"
  tier     = "ENTERPRISE"
  publishing_options {
    publish_ca_cert = true
    publish_crl     = true
  }
}

resource "google_privateca_certificate_authority" "root-ca" {
  certificate_authority_id = "my-root-ca"
  location                 = "us-central1"
  pool                     = google_privateca_ca_pool.root.name
  config {
    subject_config {
      subject {
        organization = "google"
        common_name  = "my-certificate-authority"
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
          server_auth = true
        }
      }
    }
  }
  type = "SELF_SIGNED"
  key_spec {
    algorithm = "RSA_PKCS1_4096_SHA256"
  }

  // Disable CA deletion related safe checks for easier cleanup.
  deletion_protection                    = false
  skip_grace_period                      = true
  ignore_active_certificates_on_deletion = true
}

# Sub CaPool & CA

resource "google_privateca_ca_pool" "subordinate" {
  name     = "sub-pool"
  location = "us-central1"
  tier     = "ENTERPRISE"
  publishing_options {
    publish_ca_cert = true
    publish_crl     = true
  }

  issuance_policy {
    baseline_values {
      ca_options {
        is_ca = false
      }
      key_usage {
        base_key_usage {
          digital_signature = true
          key_encipherment  = true
        }
        extended_key_usage {
          server_auth = true
        }
      }
    }
  }
}

resource "google_privateca_certificate_authority" "sub-ca" {
  pool                     = google_privateca_ca_pool.subordinate.name
  certificate_authority_id = "my-sub-ca"
  location                 = "us-central1"
  subordinate_config {
    certificate_authority = google_privateca_certificate_authority.root-ca.name
  }
  config {
    subject_config {
      subject {
        organization = "HashiCorp"
        common_name  = "my-subordinate-authority"
      }
      subject_alt_name {
        dns_names = ["hashicorp.com"]
      }
    }
    x509_config {
      ca_options {
        is_ca = true
        # Force the sub CA to only issue leaf certs
        max_issuer_path_length = 0
      }
      key_usage {
        base_key_usage {
          cert_sign = true
          crl_sign  = true
        }
        extended_key_usage {
          server_auth = true
        }
      }
    }
  }
  lifetime = "31536000s"
  key_spec {
    algorithm = "RSA_PKCS1_4096_SHA256"
  }
  type = "SUBORDINATE"

  // Disable CA deletion related safe checks for easier cleanup.
  deletion_protection                    = false
  skip_grace_period                      = true
  ignore_active_certificates_on_deletion = true
}

# Leaf cert

resource "tls_private_key" "example" {
  algorithm = "RSA"
}

resource "tls_cert_request" "example" {
  private_key_pem = tls_private_key.example.private_key_pem

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }
}

resource "google_privateca_certificate" "default" {
  pool = google_privateca_ca_pool.subordinate.name
  # Explicitly refer the sub-CA so that the certificate creation will wait for the CA creation.
  certificate_authority = google_privateca_certificate_authority.sub-ca.certificate_authority_id
  location              = "us-central1"
  lifetime              = "860s"
  name                  = "my-certificate"
  pem_csr               = tls_cert_request.example.cert_request_pem
}
# [END privateca_quickstart]
