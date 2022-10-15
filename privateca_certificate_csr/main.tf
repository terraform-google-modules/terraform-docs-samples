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

# [START privateca_create_certificate_csr]
resource "google_privateca_certificate_authority" "test-ca" {
  pool                     = "my-pool"
  certificate_authority_id = "my-certificate-authority"
  location                 = "us-central1"
  deletion_protection      = false # set to true to prevent destruction of the resource
  config {
    subject_config {
      subject {
        organization = "HashiCorp"
        common_name  = "my-certificate-authority"
      }
      subject_alt_name {
        dns_names = ["hashicorp.com"]
      }
    }
    x509_config {
      ca_options {
        # is_ca *MUST* be true for certificate authorities
        is_ca = true
      }
      key_usage {
        base_key_usage {
          # cert_sign and crl_sign *MUST* be true for certificate authorities
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


resource "google_privateca_certificate" "default" {
  pool                  = "my-pool"
  location              = "us-central1"
  certificate_authority = google_privateca_certificate_authority.test-ca.certificate_authority_id
  lifetime              = "860s"
  name                  = "my-certificate"
  pem_csr               = tls_cert_request.example.cert_request_pem
}

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

# [END privateca_create_certificate_csr]
