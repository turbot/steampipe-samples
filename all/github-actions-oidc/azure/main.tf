data "azurerm_client_config" "current" {}
data "azuread_application_published_app_ids" "well_known" {}

# Get information about the configured Azure subscription
data "azurerm_subscription" "primary" {}

# Create an AD Application
resource "azuread_application" "github_actions_app" {
  display_name = var.azuread_application_name

  # Trying to add the basic permissions listed at https://hub.steampipe.io/plugins/turbot/azuread#credentials
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "9a5d68dd-52b0-4cc2-bd40-abcf44ac3a30" # Application.Read.All
      type = "Role"
    }

    resource_access {
      id   = "b0afded3-3588-46d8-8b3d-9842eff778da" # AuditLog.Read.All
      type = "Role"
    }

    resource_access {
      id   = "7ab1d382-f21e-4acd-a863-ba3e13f7da61" # Directory.Read.All
      type = "Role"
    }

    resource_access {
      id   = "dbb9058a-0e50-45d7-ae91-66909b5d4664" # Domain.Read.All
      type = "Role"
    }

    resource_access {
      id   = "5b567255-7703-4780-807c-7be8301ae99b" # Group.Read.All
      type = "Role"
    }

    resource_access {
      id   = "e321f0bb-e7f7-481e-bb28-e3b0b32d4bd0" # IdentityProvider.Read.All
      type = "Role"
    }

    resource_access {
      id   = "246dd0d5-5bd0-4def-940b-0421030a5b68" # Policy.Read.All
      type = "Role"
    }

    resource_access {
      id   = "df021288-bdef-4463-88db-98f22de89214" # User.Read.All
      type = "Role"
    }

  }
}

# Create a Service Principal from that Application
resource "azuread_service_principal" "github_actions_sp" {
  application_id = azuread_application.github_actions_app.application_id
}

# Grant our service principal "Reader" access over the subscription
resource "azurerm_role_assignment" "github_actions_sp_permissions" {
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.github_actions_sp.object_id
}

# Create a federated identity credential for the application
resource "azuread_application_federated_identity_credential" "federated_creds" {
  application_object_id = azuread_application.github_actions_app.object_id
  display_name          = var.azuread_application_name
  description           = "Run Steampipe on GitHub Actions Demo"
  audiences             = ["api://AzureADTokenExchange"]
  issuer                = "https://token.actions.githubusercontent.com"
  subject               = "repo:${var.github_repo}:ref:refs/heads/${var.github_branch}"
}
