variable "project_id" {
  type        = string
  description = "The project id to create Workload Identity Pool"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository that needs the access token. Example: octo-org/octo-repo"
}

variable "github_branch" {
  type        = string
  description = "GitHub branch that runs the workflow. Example: demo-branch"
}

variable "pool_id" {
  type        = string
  description = "Workload Identity Pool ID"
  default     = "steampipe-gh-oidc-demo3"
}
