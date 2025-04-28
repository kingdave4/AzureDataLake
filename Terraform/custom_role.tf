data "azurerm_subscription" "primary" {}

resource "azurerm_role_definition" "github_ci_cd" {
  name        = "GitHub-CICD-Terraform-Role"
  scope       = data.azurerm_subscription.primary.id
  role_definition_id = uuidv5(data.azurerm_subscription.primary.id, "GitHub-CICD-Terraform-Role")
  description = "Custom role for GitHub Actions to deploy infrastructure and monitor logs."

  permissions {
    actions = [
      "Microsoft.Resources/subscriptions/resourceGroups/*",
      "Microsoft.Resources/deployments/*",
      "Microsoft.Compute/*/read",
      "Microsoft.Network/*/read",
      "Microsoft.Web/sites/*",
      "Microsoft.Web/serverfarms/*",
      "Microsoft.KeyVault/vaults/*",
      "Microsoft.KeyVault/vaults/secrets/*",
      "Microsoft.Storage/storageAccounts/*",
      "Microsoft.Authorization/roleAssignments/*",
      "Microsoft.Insights/components/*",
      "Microsoft.Insights/metrics/*",
      "Microsoft.Insights/eventtypes/*",
      "Microsoft.OperationalInsights/workspaces/*",
      "Microsoft.OperationalInsights/workspaces/api/query/action"
    ]

    not_actions = []
  }

  assignable_scopes = [
    data.azurerm_subscription.primary.id
  ]
}
