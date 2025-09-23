data "google_backup_dr_backup_plan_associations" "my_bpas" {
  location      = "us-central1"
  resource_type = "sqladmin.googleapis.com/Instance"
}

output "bpa_names" {
  value = [for bpa in data.google_backup_dr_backup_plan_associations.my_bpas.associations : bpa.name]
}