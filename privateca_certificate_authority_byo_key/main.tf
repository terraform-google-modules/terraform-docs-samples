# [START privateca_create_ca_byo_key]
resource "google_project_service_identity" "privateca_sa" {
  service = "privateca.googleapis.com"
}

resource "google_kms_crypto_key_iam_binding" "privateca_sa_keyuser_signerverifier" {
  crypto_key_id = "projects/keys-project/locations/us-central1/keyRings/key-ring/cryptoKeys/crypto-key"
  role          = "roles/cloudkms.signerVerifier"

  members = [
    "serviceAccount:${google_project_service_identity.privateca_sa.email}",
  ]
}

resource "google_kms_crypto_key_iam_binding" "privateca_sa_keyuser_viewer" {
  crypto_key_id = "projects/keys-project/locations/us-central1/keyRings/key-ring/cryptoKeys/crypto-key"
  role          = "roles/viewer"
  members = [
    "serviceAccount:${google_project_service_identity.privateca_sa.email}",
  ]
}

resource "google_privateca_certificate_authority" "default" {
  // This example assumes this pool already exists.
  // Pools cannot be deleted in normal test circumstances, so we depend on static pools
  pool                     = "ca-pool"
  certificate_authority_id = "my-certificate-authority"
  location                 = "us-central1"
  deletion_protection      = false # set to true to prevent destruction of the resource
  key_spec {
    cloud_kms_key_version = "projects/keys-project/locations/us-central1/keyRings/key-ring/cryptoKeys/crypto-key/cryptoKeyVersions/1"
  }

  config {
    subject_config {
      subject {
        organization = "Example, Org."
        common_name  = "Example Authority"
      }
    }
    x509_config {
      ca_options {
        # is_ca *MUST* be true for certificate authorities
        is_ca                  = true
        max_issuer_path_length = 10
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

  depends_on = [
    google_kms_crypto_key_iam_binding.privateca_sa_keyuser_signerverifier,
    google_kms_crypto_key_iam_binding.privateca_sa_keyuser_viewer,
  ]
}
# [END privateca_create_ca_byo_key]
