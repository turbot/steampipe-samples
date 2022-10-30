output "OIDC_GCP_PROJECT" {
  description = "GCP Project ID. Add this to your GitHub Secrets"
  value       = var.project_id
}

output "OIDC_GCP_IDENTITY_PROVIDER" {
  description = "GCP Workload Identity Provider ID. Add this to your GitHub Secrets"
  value       = "${google_iam_workload_identity_pool.oidc_pool.name}/providers/${google_iam_workload_identity_pool_provider.oidc_pool_provider.workload_identity_pool_provider_id}"
}

output "OIDC_GCP_SERVICE_ACCOUNT" {
  description = "GCP Service Account Email ID. Add this to your GitHub Secrets"
  value       = google_service_account.oidc_sa.email
}
