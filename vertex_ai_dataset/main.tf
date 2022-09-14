# [START vertex_ai_enable_api]
resource "google_project_service" "aiplatform" {
  provider           = google-beta
  service            = "aiplatform.googleapis.com"
  disable_on_destroy = false
}
# [END vertex_ai_enable_api]

# [START vertex_ai_dataset_image]
resource "google_vertex_ai_dataset" "image_dataset" {
  display_name          = "image-dataset"
  provider              = google-beta
  metadata_schema_uri   = "gs://google-cloud-aiplatform/schema/dataset/metadata/image_1.0.0.yaml"
  region                = "us-central1"

  depends_on            = [google_project_service.aiplatform]
}
# [END vertex_ai_dataset_image]

# [START vertex_ai_dataset_tabular]
resource "google_vertex_ai_dataset" "tabular_dataset" {
  display_name          = "tabular-dataset"
  provider              = google-beta
  metadata_schema_uri   = "gs://google-cloud-aiplatform/schema/dataset/metadata/tabular_1.0.0.yaml"
  region                = "us-central1"

  depends_on            = [google_project_service.aiplatform]
}
# [END vertex_ai_dataset_tabular]

# [START vertex_ai_dataset_text]
resource "google_vertex_ai_dataset" "text-dataset" {
  display_name          = "text-dataset"
  provider              = google-beta
  metadata_schema_uri   = "gs://google-cloud-aiplatform/schema/dataset/metadata/text_1.0.0.yaml"
  region                = "us-central1"

  depends_on            = [google_project_service.aiplatform]
}
# [END vertex_ai_dataset_text]

# [START vertex_ai_dataset_video]
resource "google_vertex_ai_dataset" "video-dataset" {
  display_name          = "video-dataset"
  provider              = google-beta
  metadata_schema_uri   = "gs://google-cloud-aiplatform/schema/dataset/metadata/video_1.0.0.yaml"
  region                = "us-central1"

  depends_on            = [google_project_service.aiplatform]
}
# [END vertex_ai_dataset_video]
