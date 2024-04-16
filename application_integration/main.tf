data "google_project" "test_project" {
}

# [START application_integration_edit_region]

resource "google_kms_key_ring" "keyring" {
  name     = "my-keyring"
  location = "us-east1"
}

resource "google_kms_crypto_key" "cryptokey" {
  name            = "crypto-key-example"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "7776000s"
  depends_on      = [google_kms_key_ring.keyring]
}

resource "google_kms_crypto_key_version" "test_key" {
  crypto_key = google_kms_crypto_key.cryptokey.id
  depends_on = [google_kms_crypto_key.cryptokey]
}

resource "google_service_account" "service_account" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_integrations_client" "example" {
  location                = "us-east1"
  create_sample_workflows = true
  run_as_service_account  = google_service_account.service_account.email
  cloud_kms_config {
    kms_location   = "us-east1"
    kms_ring       = google_kms_key_ring.keyring.id
    key            = google_kms_crypto_key.cryptokey.id
    key_version    = google_kms_crypto_key_version.test_key.id
    kms_project_id = data.google_project.test_project.project_id
  }
  depends_on = [google_kms_crypto_key_version.test_key, google_service_account.service_account]
}
# [END application_integration_edit_region]
