output "account_id" {
  description = "Current AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "openid_arn" {
  description = "ARN of the OIDC"
  value       = aws_iam_openid_connect_provider.github_actions.arn
}

output "OIDC_AWS_ROLE_TO_ASSUME" {
  description = "ARN of the IAM Assume Role. Add this to your GitHub Secrets"
  value       = aws_iam_role.openid_role.arn
}
