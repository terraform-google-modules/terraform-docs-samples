/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# Google Cloud Documentation: https://cloud.google.com/iam/docs/deny-access#create-deny-policy
# Hashicorp Documentation: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_deny_policy

# [START iam_create_deny_policy]
data "google_project" "default" {
}

# Create an Example Service A/C
resource "google_service_account" "default" {
  display_name = "IAM Deny Example - Service Account"
  account_id   = "example-sa"
  project      = data.google_project.default.project_id
}

# Create IAM Deny Policy for the Example SA
resource "google_iam_deny_policy" "default" {
  provider     = google-beta
  parent       = urlencode("cloudresourcemanager.googleapis.com/projects/${data.google_project.default.project_id}")
  name         = "my-deny-policy"
  display_name = "My deny policy."
  rules {
    deny_rule {
      denied_principals  = ["principal://iam.googleapis.com/projects/-/serviceAccounts/${google_service_account.default.email}"]
      denied_permissions = ["iam.googleapis.com/roles.create"]
    }
  }
}
# [END iam_create_deny_policy]
