# [START vertex_ai_enable_api]
resource "google_project_service" "aiplatform" {
  provider           = google-beta
  service            = "aiplatform.googleapis.com"
  disable_on_destroy = false
}
# [END vertex_ai_enable_api]

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

  depends_on = [google_project_service.aiplatform]
}
# [END vertex_ai_user_managed_notebooks_instance_basic]

# [START vertex_ai_user_managed_notebooks_instance_container]
resource "google_notebooks_instance" "container_instance" {
  name         = "notebooks-instance-container"
  location     = "us-central1-a"
  machine_type = "e2-medium"

  metadata = {
    proxy-mode = "service_account"
    terraform  = "true"
  }

  container_image {
    repository = "gcr.io/deeplearning-platform-release/base-cpu"
    tag        = "latest"
  }

  depends_on = [google_project_service.aiplatform]
}
# [END vertex_ai_user_managed_notebooks_instance_container]

# [START vertex_ai_user_managed_notebooks_instance_gpu]
resource "google_notebooks_instance" "gpu_instance" {
  name         = "notebooks-instance-gpu"
  location     = "us-central1-a"
  machine_type = "n1-standard-1"

  install_gpu_driver = true
  accelerator_config {
    type       = "NVIDIA_TESLA_T4"
    core_count = 1
  }

  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "tf-latest-gpu"
  }

  depends_on = [google_project_service.aiplatform]
}
# [END vertex_ai_user_managed_notebooks_instance_gpu]
