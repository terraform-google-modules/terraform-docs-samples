/**
 * Copyright 2024 Google LLC
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
/*
Create a workflow that reads and stores the current date and then retrieves
a list of Wikipedia articles related to the day of the week.
See https://cloud.google.com/workflows/docs/create-workflow-terraform
before running the code snippet.
*/

# [START workflows_terraform_api_enable]
# Enable Workflows API
resource "google_project_service" "default" {
  service            = "workflows.googleapis.com"
  disable_on_destroy = false
}
# [END workflows_terraform_api_enable]

# [START workflows_terraform_serviceaccount_create]
# Create a dedicated service account
resource "google_service_account" "default" {
  account_id   = "sample-workflows-sa"
  display_name = "Sample Workflows Service Account"
}
# [END workflows_terraform_serviceaccount_create]

# [START workflows_terraform_workflow_deploy]
# Create a workflow
resource "google_workflows_workflow" "default" {
  name            = "sample-workflow"
  region          = "us-central1"
  description     = "A sample workflow"
  service_account = google_service_account.default.id
  labels = {
    env = "test"
  }
  user_env_vars = {
    url = "https://timeapi.io/api/Time/current/zone?timeZone=Europe/Amsterdam"
  }
  source_contents = <<-EOF
  # This is a sample workflow that you can replace with your source code
  #
  # The workflow does the following:
  # - Retrieves the current date from a public API and stores the
  #   response in `currentDate`
  # - Retrieves a list of Wikipedia articles from a public API related
  #   to the day of the week stored in `currentDate`
  # - Returns the list of articles in the workflow output
  #
  # Note that when you define workflows in Terraform, variables must be
  # escaped with two dollar signs ($$) and not a single sign ($)

  - getCurrentDate:
      call: http.get
      args:
          url: $${sys.get_env("url")}
      result: currentDate
  - readWikipedia:
      call: http.get
      args:
          url: https://en.wikipedia.org/w/api.php
          query:
              action: opensearch
              search: $${currentDate.body.dayOfWeek}
      result: wikiResult
  - returnOutput:
      return: $${wikiResult.body[1]}
EOF

  depends_on = [google_project_service.default]
}
# [END workflows_terraform_workflow_deploy]
