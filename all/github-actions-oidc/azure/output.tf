output "OIDC_AZURE_CLIENT_ID" {
  description = "Client ID. Add this to your GitHub Secrets"
  value       = azuread_application.github_actions_app.application_id
}

output "OIDC_AZURE_SUBSCRIPTION_ID" {
  description = "Subscription ID. Add this to your GitHub Secrets"
  value       = data.azurerm_client_config.current.subscription_id
}

output "OIDC_AZURE_TENANT_ID" {
  description = "Tenant ID. Add this to your GitHub Secrets"
  value       = data.azurerm_client_config.current.tenant_id
}
