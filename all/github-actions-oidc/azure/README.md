# OpenID Connect (OIDC) in Azure

OpenID Connect (OIDC) allows your GitHub Actions workflows to access resources in Azure, without needing to store the Azure credentials as long-lived GitHub secrets. You can learn more [here](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect).

## Implementation details

This Terraform template creates the following Azure resources:

- `Azure > Active Directory > Application (steampipe_gh_oidc_demo)`
- `Azure > Active Directory > Service Principal (steampipe_gh_oidc_demo)`

**NOTE**: The Azure AD Service Principal(steampipe_gh_oidc_demo) has the BuiltInRole `Reader` assigned.

## Prerequisites

To run this example, you must install:

- [Terraform](https://www.terraform.io) Version 13, minimum.
- [Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest) and [AzureAD](https://registry.terraform.io/providers/hashicorp/azuread/latest) Terraform Providers.

This example is tested with the following versions.

- Terraform v0.13.7
- provider registry.terraform.io/hashicorp/azuread v2.30.0
- provider registry.terraform.io/hashicorp/azurerm v3.29.1

**NOTE**: Once the Azure AD Application is created, you have to manually [Grant admin consent for tenant](https://learn.microsoft.com/en-us/azure/active-directory/manage-apps/grant-admin-consent).

### Authentication and Configuration

You must set your Azure environment variables to create above resources in your Azure Subscription. Please refer to the Terraform documentation on Authentication and Configuration for [AzureAD](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs#authenticating-to-azure-active-directory) and [AzureRM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure).

## Running the example

Scripts can be run in the folder that contains the script.

### Configure the script

Update [default.tfvars](default.tfvars) or create a new Terraform configuration file.

Variables that are exposed by this script are:

- github_repo
- github_branch
- azuread_application_name

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

A sample GitHub Actions Workflow for AWS is available [here](./steampipe-sample-azure.yml). Below GitHub Secrets are to be added in your repository.

- OIDC_AZURE_CLIENT_ID
- OIDC_AZURE_TENANT_ID
- OIDC_AZURE_SUBSCRIPTION_ID
- OIDC_SLACK_CHANNEL_ID
- OIDC_SLACK_OAUTH_ACCESS_TOKEN
