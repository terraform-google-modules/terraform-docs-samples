# [START bigquery_datapolicy_data_masking_policy]
terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 7.43.0"
    }
  }
}

provider "google-beta" {
  region = "us-central1"
}

# Get the current project automatically
data "google_project" "default" {}

# 1. Define a Tag Key for Data Governance
resource "google_tags_tag_key" "default" {
  provider   = google-beta
  parent     = "projects/${data.google_project.default.project_id}"
  short_name = "data-governance-key"
  purpose    = "DATA_GOVERNANCE"
}

# 2. Define a Tag Value
resource "google_tags_tag_value" "default" {
  provider   = google-beta
  parent     = "tagKeys/${google_tags_tag_key.default.name}"
  short_name = "data-governance-value"
}

# 3. Create a Dataset
resource "google_bigquery_dataset" "default" {
  provider   = google-beta
  dataset_id = "my_dataset"
  location   = "US"
}

# 4. Create a Table tagging the column with the Data Governance Tag
resource "google_bigquery_table" "default" {
  provider   = google-beta
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = "my_table"

  schema = <<EOF
[
  {
    "name": "sensitive_column",
    "type": "STRING",
    "mode": "NULLABLE",
    "dataGovernanceTagsInfo": {
      "dataGovernanceTags": {
        "${google_tags_tag_key.default.namespaced_name}": "${google_tags_tag_value.default.short_name}"
      }
    }
  }
]
EOF

  deletion_protection = false
}

# 5. Create a Data Masking Policy protecting columns with the Tag
resource "google_bigquery_datapolicyv2_data_policy" "default" {
  provider         = google-beta
  location         = "us-central1"
  data_policy_type = "DATA_MASKING_POLICY"
  data_policy_id   = "data_masking_policy"

  data_masking_policy {
    predefined_expression = "SHA256"
  }

  data_governance_tag {
    key   = google_tags_tag_key.default.namespaced_name
    value = google_tags_tag_value.default.short_name
  }

  grantees = [
    "user:user@example.com"
  ]
}
# [END bigquery_datapolicy_data_masking_policy]

