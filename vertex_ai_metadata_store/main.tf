# [START vertex_ai_metadata_store]
resource "google_vertex_ai_metadata_store" "default" {
  name          = "test-store"
  provider      = google-beta
  description   = "Store to test the terraform module"
  region        = "us-central1"
}
# [END vertex_ai_metadata_store]