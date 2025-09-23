data "google_backup_dr_data_source_references" "all_csql_data_source_references" {
  location      = "us-central1"
  resource_type = "sqladmin.googleapis.com/Instance"
}

output "csql_data_source_references" {
  value = data.google_backup_dr_data_source_references.all_csql_data_source_references.data_source_references
}
