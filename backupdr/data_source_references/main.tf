data "google_backup_dr_data_source_references" "my_sql_references" {
  provider      = google-beta
  location      = "us-central1"
  resource_type = "sqladmin.googleapis.com/Instance"
}

output "first_sql_reference_name" {
  value = data.google_backup_dr_data_source_references.my_sql_references.data_source_references[0].name
}
