# Retrieve information about the organization.
output "my_org_details" {
  value = pipes_organization.pipes_demo
}

# Retrieve information about the orginization workspace.
output "my_org_workspace_details" {
  value = pipes_workspace.pipes_demo_workspace
}