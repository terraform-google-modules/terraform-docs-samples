# [START vertex_ai_notebooks_api_enable]
resource "google_project_service" "notebooks" {
  provider           = google-beta
  service            = "notebooks.googleapis.com"
  disable_on_destroy = false
}
# [END vertex_ai_notebooks_api_enable]

# [START vertex_ai_managed_notebooks_runtime_basic]
resource "google_notebooks_runtime" "basic_runtime" {
  name     = "notebooks-runtime-basic"
  location = "us-central1"

  access_config {
    access_type   = "SINGLE_USER"
    runtime_owner = "admin@hashicorptest.com"
  }

  virtual_machine {
    virtual_machine_config {
      machine_type = "n1-standard-4"
      data_disk {
        initialize_params {
          disk_size_gb = "100"
          disk_type    = "PD_STANDARD"
        }
      }
    }
  }

  depends_on = [
    google_project_service.notebooks
  ]
}
# [END vertex_ai_managed_notebooks_runtime_basic]

