/*
Create all service agents for aiplatform.googleapis.com for
the `default` project, then grant roles to the service agents.
*/

# [START iam_create_project_level_service_agent]
data "google_project" "default" {
}

# Define a folder
data "google_folder" "default" {
  folder = "folders/123456789"
}

# Define an organization
data "google_organization" "default" {
  organization = "organizations/6781234567"
}

# Create all project-level bigquery.googleapis.com service agents
resource "google_workload_identity_service_agent" "primary" {
  parent = "projects/${data.google_project.default.number}/locations/global/serviceProducers/bigquery.googleapis.com"
}

# Create all folder-level accessapproval.googleapis.com service agents
resource "google_workload_identity_service_agent" "primaryfolder" {
  parent = "folders/${data.google_folder.default.folder_id}/locations/global/serviceProducers/accessapproval.googleapis.com"
}

# Create all organization-level accessapproval.googleapis.com service agents
resource "google_workload_identity_service_agent" "primaryorganization" {
  parent = "organizations/${data.google_organization.default.org_id}/locations/global/serviceProducers/accessapproval.googleapis.com"
}


# [END iam_create_project_level_service_agent]

# [START iam_grant_roles_to_service_agents]
# Grant roles to BigQuery service agents for project
resource "google_project_iam_member" "service_agents" {
  for_each = {
    for i, agent in google_workload_identity_service_agent.primary.service_agents :
    i => agent if try(agent.role, "") != ""
  }
  project = data.google_project.default.project_id
  role    = each.value.role
  member  = each.value.principal
}
# [END iam_grant_roles_to_service_agents]