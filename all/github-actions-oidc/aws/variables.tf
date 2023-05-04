variable "github_repo" {
  type        = string
  description = "GitHub repository that needs the access token. Example: octo-org/octo-repo"
}

variable "github_branch" {
  type        = string
  description = "GitHub branch that runs the workflow. Example: demo-branch"
}

variable "aws_iam_role_name" {
  type        = string
  description = "Name of the AWS IAM Role to create. Example: steampipe_gh_oidc_demo"
  default     = "steampipe-gh-oidc-demo"
}
