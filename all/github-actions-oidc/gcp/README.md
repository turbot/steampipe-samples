# OpenID Connect (OIDC) in GCP

OpenID Connect (OIDC) allows your GitHub Actions workflows to access resources in Google Cloud Platform (GCP), without needing to store the GCP credentials as long-lived GitHub secrets. You can learn more [here](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect).

## Implementation details

This Terraform template creates the following GCP resources:

- `GCP > IAM > Workload Identity Pool (steampipe-gh-oidc-demo)`
- `GCP > IAM > Workload Identity Pool Provider (steampipe-gh-oidc-demo-provider)`
- `GCP > IAM > Service Account (steampipe-gh-oidc-demo-sa)`

**NOTE**: The GCP Service Account(steampipe-gh-oidc-demo-sa) has the GCP predefined role "roles/viewer" assigned.

## Prerequisites

To run this example, you must install:

- [Terraform](https://www.terraform.io) Version 13, minimum.
- [GCP Terraform Provider](https://registry.terraform.io/providers/hashicorp/google/latest).

This example is tested with the following versions.

- Terraform v0.13.7
- provider registry.terraform.io/hashicorp/google v4.31.0

### Authentication and Configuration

You must set your GCP environment variables to create above resources in your GCP Project Account. Please refer to the Terraform documentation on [Authentication and Configuration](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#authentication).

## Running the example

Scripts can be run in the folder that contains the script.

### Configure the script

Update [default.tfvars](default.tfvars) or create a new Terraform configuration file.

Variables that are exposed by this script are:

- project_id
- github_repo
- github_branch
- pool_id

Open the file [variables.tf](variables.tf) for further details.

### Initialize Terraform

If not previously run then initialize Terraform to get all necessary providers.

Command: `terraform init`

### Apply using default configuration

If seeking to apply the configuration using the configuration file [defaults.tfvars](defaults.tfvars).

Command: `terraform apply -var-file=default.tfvars`

### Apply using custom configuration

If seeking to apply the configuration using a custom configuration file `<custom_filename>.tfvars`.

Command: `terraform apply -var-file=<custom_filename>.tfvars`

### Destroy using default configuration

If seeking to apply the configuration using the configuration file [defaults.tfvars](defaults.tfvars).

Command: `terraform destroy -var-file=default.tfvars`

### Destroy using custom configuration

If seeking to apply the configuration using a custom configuration file `<custom_filename>.tfvars`.

Command: `terraform destroy -var-file=<custom_filename>.tfvars`

## GitHub Actions Workflow

A sample GitHub Actions Workflow for AWS is available [here](./steampipe-sample-gcp.yml). Below GitHub Secrets are to be added in your repository.

- OIDC_GCP_IDENTITY_PROVIDER
- OIDC_GCP_SERVICE_ACCOUNT
- OIDC_GCP_PROJECT
- OIDC_SLACK_CHANNEL_ID
- OIDC_SLACK_OAUTH_ACCESS_TOKEN
