data "google_backup_dr_backup_plan_associations" "csql_bpas" {
  location      = "us-central1"
  resource_type = "sqladmin.googleapis.com/Instance"
}

output "csql_bpas" {
  backup_plan_associations = google_backup_dr_backup_plan_associations.csql_bpas
}