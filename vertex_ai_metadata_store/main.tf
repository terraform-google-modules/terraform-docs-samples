# [START vertex_ai_metadata_store]
resource "google_vertex_ai_metadata_store" "default" {
  name          = "test-store"
  provider      = google-beta
  description   = "Example metadata store"
  region        = "us-central1"
}
# [END vertex_ai_metadata_store]