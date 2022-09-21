resource "google_project_service" "notebooks" {
  provider           = google-beta
  service            = "notebooks.googleapis.com"
  disable_on_destroy = false
}

# [START vertex_ai_user_managed_notebooks_instance_basic]
resource "google_notebooks_instance" "basic_instance" {
  name         = "notebooks-instance-basic"
  provider     = google-beta
  location     = "us-central1-a"
  machine_type = "e2-medium"

  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "tf-latest-cpu"
  }

  depends_on = [
    google_project_service.notebooks
  ]
}
# [END vertex_ai_user_managed_notebooks_instance_basic]
