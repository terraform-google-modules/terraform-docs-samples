# [START compute_reservation_create_local_reservation]

resource "google_compute_reservation" "gce_reservation_local" {
  name = "gce-reservation-local"
  zone = "us-central1-c"

  share_settings {
    share_type = "LOCAL"
  }

  specific_reservation {
    count = 1
    instance_properties {
      machine_type = "n2-standard-2"
    }
  }
}

# [END compute_reservation_create_local_reservation]
