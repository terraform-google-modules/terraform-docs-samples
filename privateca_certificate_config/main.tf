# [START privateca_create_certificate_config]
resource "google_privateca_certificate_authority" "test-ca" {
  certificate_authority_id = "my-example-certificate-authority"
  location = "us-central1"
  pool = "my-pool"
  ignore_active_certificates_on_deletion = true
  deletion_protection = false # set to true to prevent destruction of the resource
  config {
    subject_config {
      subject {
        organization = "HashiCorp"
        common_name = "my-certificate-authority"
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
          cert_sign = true
          crl_sign = true
        }
        extended_key_usage {
          server_auth = true
        }
      }
    }
  }
  key_spec {
    algorithm = "RSA_PKCS1_4096_SHA256"
  }
}

resource "google_privateca_certificate" "default" {
  pool = "my-pool"
  location = "us-central1"
  certificate_authority = google_privateca_certificate_authority.test-ca.certificate_authority_id
  lifetime = "860s"
  name = "my-example-certificate"
  config {
    subject_config  {
      subject {
        common_name = "san1.example.com"
        country_code = "us"
        organization = "google"
        organizational_unit = "enterprise"
        locality = "mountain view"
        province = "california"
        street_address = "1600 amphitheatre parkway"
      } 
      subject_alt_name {
        email_addresses = ["email@example.com"]
        ip_addresses = ["127.0.0.1"]
        uris = ["http://www.ietf.org/rfc/rfc3986.txt"]
      }
    }
    x509_config {
      ca_options {
        is_ca = false
      }
      key_usage {
        base_key_usage {
          crl_sign = false
          decipher_only = false
        }
        extended_key_usage {
          server_auth = false
        }
      }
    }
    public_key {
      format = "PEM"
      key = base64encode(data.tls_public_key.example.public_key_pem)
    }
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
}

data "tls_public_key" "example" {
  private_key_pem = tls_private_key.example.private_key_pem
}

# [END privateca_create_certificate_config]
