# [START compute_autoscale_schedule]
resource "google_compute_autoscaler" "default" {
  provider = google-beta
  name     = "my-autoscaler"
  zone     = "us-central1-f"
  target   = google_compute_instance_group_manager.default.id

  autoscaling_policy {
    max_replicas    = 5
    min_replicas    = 1
    cooldown_period = 60

    metric {
      name                       = "pubsub.googleapis.com/subscription/num_undelivered_messages"
      filter                     = "resource.type = pubsub_subscription AND resource.label.subscription_id = our-subscription"
      single_instance_assignment = 65535
    }

    scaling_schedules {
      name                   = "every-weekday-morning"
      description            = "Increase to 2 every weekday at 7AM for 12 hours."
      min_required_replicas  = 2
      schedule               = "0 7 * * MON-FRI"
      time_zone              = "America/New_York"
      duration_sec           = 43200
    }
  }
}
# [END compute_autoscale_schedule]

resource "google_compute_instance_template" "default" {
  name           = "my-instance-template"
  machine_type   = "e2-medium"
  can_ip_forward = false

  tags = ["foo", "bar"]

  disk {
    source_image = data.google_compute_image.debian_9.id
  }

  network_interface {
    network = "default"
  }

  metadata = {
    foo = "bar"
  }

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-ro"]
  }
}


resource "google_compute_instance_group_manager" "default" {

  name = "my-igm"
  zone = "us-central1-f"

  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }

  base_instance_name = "autoscaler-sample"
}

data "google_compute_image" "debian_9" {

  family  = "debian-11"
  project = "debian-cloud"
}
