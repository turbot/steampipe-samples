resource "google_iam_workload_identity_pool" "oidc_pool" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  description               = "Workload Identity Pool managed by Terraform"
  disabled                  = false
}

resource "google_iam_workload_identity_pool_provider" "oidc_pool_provider" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.oidc_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "${var.pool_id}-provider"
  description                        = "Workload Identity Pool Provider managed by Terraform"
  attribute_mapping = {
    "google.subject" = "assertion.sub"
    "attribute.full" = "assertion.repository+assertion.ref"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "oidc_sa" {
  project      = var.project_id
  account_id   = "${var.pool_id}-sa"
  display_name = "${var.pool_id}-sa"
}

resource "google_project_iam_binding" "sa_viewer_role" {
  project = var.project_id
  role    = "roles/viewer"

  members = ["serviceAccount:${google_service_account.oidc_sa.email}"]
}

resource "google_service_account_iam_member" "wif_sa" {
  service_account_id = google_service_account.oidc_sa.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.oidc_pool.name}/attribute.full/${var.github_repo}refs/heads/${var.github_branch}"
}
