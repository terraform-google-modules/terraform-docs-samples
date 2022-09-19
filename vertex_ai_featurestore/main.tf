# [START vertex_ai_enable_api]
resource "google_project_service" "aiplatform" {
  provider           = google-beta
  service            = "aiplatform.googleapis.com"
  disable_on_destroy = false
}
# [END vertex_ai_enable_api]

# [START vertex_ai_featurestore]
resource "random_id" "featurestore_name_suffix" {
  byte_length = 8
}

resource "google_vertex_ai_featurestore" "main" {
  name          = "featurestore_${random_id.featurestore_name_suffix.hex}"
  provider      = google-beta
  region        = "us-central1"
  labels        = {
    environment = "testing"
  }

  online_serving_config {
    fixed_node_count = 1
  }

  force_destroy = true

  depends_on    = [google_project_service.aiplatform]
}
# [END vertex_ai_featurestore]
