/**
 * Copyright 2026 Google LLC
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
Create all service agents for aiplatform.googleapis.com for
the `default` project, then grant roles to the service agents.
*/

#[START iam_workloadidentity_bigquery_service_agents]
data "google_project" "default" {
}

#Create all project-level bigquery.googleapis.com service agents
resource "google_workload_identity_service_agent" "primary" {
  parent = "projects/${data.google_project.default.number}/locations/global/serviceProducers/bigquery.googleapis.com"
}
#[END iam_workloadidentity_bigquery_service_agents]

#[START iam_workloadidentity_bigquery_iam_member]
#Grant roles to BigQuery service agents for project
resource "google_project_iam_member" "service_agents" {
  for_each = {
    for i, agent in google_workload_identity_service_agent.primary.service_agents :
    i => agent if try(agent.role, "") != ""
  }
  project = data.google_project.default.project_id
  role    = each.value.role
  member  = each.value.principal
}
#[END iam_workloadidentity_bigquery_iam_member]
