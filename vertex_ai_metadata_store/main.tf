# [START vertex_ai_enable_api]
resource "google_project_service" "aiplatform" {
  provider           = google-beta
  service            = "aiplatform.googleapis.com"
  disable_on_destroy = false
}
# [END vertex_ai_enable_api]

# [START vertex_ai_metadata_store]
resource "google_vertex_ai_metadata_store" "main" {
  name          = "test-store"
  provider      = google-beta
  description   = "Example metadata store"
  region        = "us-central1"
  
  depends_on    = [google_project_service.aiplatform]
}
# [END vertex_ai_metadata_store]