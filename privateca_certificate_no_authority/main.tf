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

# [START privateca_create_certificate]
resource "google_privateca_certificate_authority" "authority" {
  // This example assumes this pool already exists.
  // Pools cannot be deleted in normal test circumstances, so we depend on static pools
  pool                     = "my-pool"
  certificate_authority_id = "my-sample-certificate-authority"
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
        is_ca = true
      }
      key_usage {
        base_key_usage {
          digital_signature = true
          cert_sign         = true
          crl_sign          = true
        }
        extended_key_usage {
          server_auth = true
        }
      }
    }
  }
  lifetime = "86400s"
  key_spec {
    algorithm = "RSA_PKCS1_4096_SHA256"
  }
}


resource "google_privateca_certificate" "default" {
  pool     = "my-pool"
  location = "us-central1"
  lifetime = "860s"
  name     = "my-sample-certificate"
  config {
    subject_config {
      subject {
        common_name         = "san1.example.com"
        country_code        = "us"
        organization        = "google"
        organizational_unit = "enterprise"
        locality            = "mountain view"
        province            = "california"
        street_address      = "1600 amphitheatre parkway"
        postal_code         = "94109"
      }
    }
    x509_config {
      ca_options {
        is_ca = false
      }
      key_usage {
        base_key_usage {
          crl_sign = true
        }
        extended_key_usage {
          server_auth = true
        }
      }
    }
    public_key {
      format = "PEM"
      key    = base64encode(data.tls_public_key.example.public_key_pem)
    }
  }
  // Certificates require an authority to exist in the pool, though they don't
  // need to be explicitly connected to it
  depends_on = [google_privateca_certificate_authority.authority]
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
}

data "tls_public_key" "example" {
  private_key_pem = tls_private_key.example.private_key_pem
}
# [END privateca_create_certificate]
