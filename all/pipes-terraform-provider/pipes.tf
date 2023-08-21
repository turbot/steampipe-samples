# Create an organization "Pipes Demo Org"
resource "pipes_organization" "pipes_demo" {
  handle       = "pipes-demo-org"
  display_name = "Pipes Demo"
}

# Add user with handle "vkumbha-mnuv" to the Organization as a member
resource "pipes_organization_member" "org_member" {
  organization = pipes_organization.pipes_demo.handle
  user_handle  = "vkumbha-mnuv"
  role         = "member"
}

# Create AWS Connections for the organization
resource "pipes_connection" "aws_connections" {
  for_each     = var.aws_connections
  organization = pipes_organization.pipes_demo.handle
  plugin       = "aws"
  handle       = each.key
  config = jsonencode({
    regions     = each.value.regions
    role_arn    = each.value.role_arn
    external_id = each.value.external_id
  })
}

# Create an organization workspace
resource "pipes_workspace" "pipes_demo_workspace" {
  organization = pipes_organization.pipes_demo.handle
  handle       = "awsworkspace"
}

# Associate connection(s) to an organization workspace
resource "pipes_workspace_connection" "pipes_demo_connections" {
  depends_on        = [pipes_connection.aws_connections]
  for_each          = var.aws_connections
  organization      = pipes_organization.pipes_demo.handle
  workspace_handle  = pipes_workspace.pipes_demo_workspace.handle
  connection_handle = each.key
}

# Add user with handle "vkumbha-mnuv" as an owner to the workspace
resource "pipes_organization_workspace_member" "pipes_demo_workspace_member" {
  depends_on       = [pipes_organization_member.org_member]
  organization     = pipes_organization.pipes_demo.handle
  workspace_handle = pipes_workspace.pipes_demo_workspace.handle
  user_handle      = "vkumbha-mnuv"
  role             = "owner"
}

# Create an organization workspace aggregator
resource "pipes_workspace_aggregator" "all_aws_aggregator" {
  organization = pipes_organization.pipes_demo.handle
  workspace    = pipes_workspace.pipes_demo_workspace.handle
  handle       = "all_aws"
  plugin       = "aws"
  connections  = ["aws*"]
}

# Schedule a custom query pipeline to run weekly
resource "pipes_workspace_pipeline" "aws_s3_bucket_versioning_report" {
  organization = pipes_organization.pipes_demo.handle
  workspace    = pipes_workspace.pipes_demo_workspace.handle
  title        = "AWS S3 Bucket Versioning Report"
  pipeline     = "pipeline.snapshot_query"
  frequency = jsonencode({
    "type" : "interval",
    "schedule" : "weekly"
  })
  args = jsonencode({
    "resource" : "custom.dashboard.sql",
    "snapshot_title" : "AWS S3 Bucket Versioning Report",
    "sql" : <<EOQ
select
  name,
  region,
  account_id,
  versioning_enabled
from
  all_aws.aws_s3_bucket
where
  not versioning_enabled
EOQ
    "visibility" : "workspace",
    "notifications" : { "slack" : var.slack_webhook },
    # "notifications" : {},
  })
  tags = jsonencode({
    "provider" : "aws",
    "type" : "report"
  })
}

# Create an organization workspace mod
resource "pipes_workspace_mod" "aws_compliance_mod" {
  organization     = pipes_organization.pipes_demo.handle
  workspace_handle = pipes_workspace.pipes_demo_workspace.handle
  path             = "github.com/turbot/steampipe-mod-aws-compliance"
}

# Schedule AWS CIS v2.0.0 benchmark to run weekly
resource "pipes_workspace_pipeline" "weekly_cis_pipeline" {
  depends_on   = [pipes_workspace_mod.aws_compliance_mod]
  organization = pipes_organization.pipes_demo.handle
  workspace    = pipes_workspace.pipes_demo_workspace.handle
  title        = "Weekly CIS Job"
  pipeline     = "pipeline.snapshot_dashboard"
  frequency = jsonencode({
    "type" : "interval",
    "schedule" : "weekly"
  })
  args = jsonencode({
    "resource" : "aws_compliance.benchmark.cis_v200",
    "snapshot_tags" : {
      "series" : "weekly_cis"
    },
    "visibility" : "workspace",
    "inputs" : {},
    "notifications" : { "slack" : var.slack_webhook },
    # "notifications" : {},
    "variables" : {}
  })
  tags = jsonencode({
    "name" : "weekly_cis_pipeline"
  })
}
