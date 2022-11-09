# OpenID Connect (OIDC) in AWS

OpenID Connect (OIDC) allows your GitHub Actions workflows to access resources in Amazon Web Services (AWS), without needing to store the AWS credentials as long-lived GitHub secrets. You can learn more [here](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect).

## Implementation details

This Terraform template creates the following AWS resources:

- `AWS > IAM > Identity provider > token.actions.githubusercontent.com`
- `AWS > IAM > Role (steampipe_gh_oidc_demo)`

**NOTE**: The AWS IAM Role(steampipe_gh_oidc_demo) is attached with the AWS Managed policy "arn:aws:iam::aws:policy/ReadOnlyAccess".

## Prerequisites

To run this example, you must install:

- [Terraform](https://www.terraform.io) Version 0.13, minimum.
- [AWS Terraform Provider](https://registry.terraform.io/providers/hashicorp/aws/latest).

This example is tested with the following versions.

- Terraform v0.13.7
- provider registry.terraform.io/hashicorp/aws v3.75.2

### Authentication and Configuration

You must set your AWS environment variables to create above resources in your AWS Account. Please refer to the Terraform documentation on [Authentication and Configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration).

## Running the example

Scripts can be run in the folder that contains the script.

### Configure the script

Update [default.tfvars](default.tfvars) or create a new Terraform configuration file.

Variables that are exposed by this script are:

- github_repo
- github_branch
- aws_iam_role_name

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

A sample GitHub Actions Workflow for AWS is available [here](./steampipe-sample-aws-workflow.yml). Below GitHub Secrets are to be added in your repository.

- OIDC_AWS_ROLE_TO_ASSUME
- OIDC_SLACK_CHANNEL_ID
- OIDC_SLACK_OAUTH_ACCESS_TOKEN
