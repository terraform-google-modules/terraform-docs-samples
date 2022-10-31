# [START compute_disk_clone_single_zone]
resource "google_compute_disk" "default" {
  name  = "disk-name1"
  type  = "pd-ssd"
  zone  = "us-central1-a"
  image = "debian-11-bullseye-v20220719"
  labels = {
    environment = "dev"
  }
  physical_block_size_bytes = 4096
}
# [END compute_disk_clone_single_zone]

# [START compute_disk_clone_regional]
resource "google_compute_region_disk" "regiondisk" {
  name                      = "region-disk-name"
  snapshot                  = google_compute_snapshot.snapdisk.id
  type                      = "pd-ssd"
  region                    = "us-central1"
  physical_block_size_bytes = 4096

  replica_zones = ["us-central1-a", "us-central1-f"]
}
# [END compute_disk_clone_regional]

resource "google_compute_disk" "disk" {
  name  = "disk-name2"
  image = "debian-cloud/debian-11"
  size  = 50
  type  = "pd-ssd"
  zone  = "us-central1-a"
}

resource "google_compute_snapshot" "snapdisk" {
  name        = "snapshot-name"
  source_disk = google_compute_disk.disk.name
  zone        = "us-central1-a"
}
