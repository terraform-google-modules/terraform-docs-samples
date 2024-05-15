# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# [START storage_remote_terraform_backend_template]
# In this example, we show how to provision a Cloud Storage bucket and then
# generate a Terraform backend configuration file.
# To run this example, do the following:
#
# 1. Initialize Terraform with a local backend:
#
#    terraform init
#
# 2. Provision resources and create a Cloud Storage bucket for the Terraform
#    remote backend:
#
#    terraform apply
#
# 3. Migrate Terraform state to the remote Cloud Storage backend:
#
#    terraform init -migrate-state

# [START storage_bucket_tf_with_versioning_pap_uap_no_destroy]
resource "random_id" "terraform_remote_backend_bucket_random_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "terraform_remote_backend" {
  name     = "${random_id.terraform_remote_backend_bucket_random_prefix.hex}-terraform-remote-backend"
  location = "US"

  force_destroy               = false
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}
# [END storage_bucket_tf_with_versioning_pap_uap_no_destroy]

# [START storage_remote_backend_local_file]
# Create a
resource "local_file" "backend_configuration_file" {
  file_permission = "0644"
  filename        = "${path.module}/backend.tf"

  # You can store the template in a file and use the templatefile function for
  # more modularity, if you prefer, instead of storing the template inline as
  # we do here.
  content = <<-EOT
  terraform {
    backend "gcs" {
      bucket = "${google_storage_bucket.terraform_remote_backend.name}"
    }
  }
  EOT
}
# [END storage_remote_backend_local_file]
# [END storage_remote_terraform_backend_template]
