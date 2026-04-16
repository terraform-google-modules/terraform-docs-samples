/*
Create all service agents for aiplatform.googleapis.com for
the `default` project, then grant roles to the service agents.
*/

# [START iam_create_project_level_service_agent]
data "google_project" "default" {
}

# Create all project-level bigquery.googleapis.com service agents
resource "google_workload_identity_service_agent" "primary" {
  parent = "projects/${data.google_project.default.number}/locations/global/serviceProducers/bigquery.googleapis.com"
}
# [END iam_create_project_level_service_agent]

# [START iam_grant_roles_to_service_agents]
locals {
  service_agent_bindings = {
    for agent in google_workload_identity_service_agent.primary.service_agents :
    agent.role => agent.principal... if try(agent.role, null) != null
  }
}

# Grant roles to BigQuery service agents
resource "google_project_iam_member" "service_agents" {
  for_each = local.service_agent_bindings
  project  = data.google_project.default.project_id
  role     = each.key
  member  = each.value
}
# [END iam_grant_roles_to_service_agents]