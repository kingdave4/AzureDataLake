resource "azurerm_role_definition" "github_ci_cd" {
  name        = "GitHub CICD Terraform Role"
  scope       = "/subscriptions/${var.subscription_id}"
  description = "Custom role for GitHub Actions to deploy infra and monitor logs"

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
    "/subscriptions/${var.subscription_id}"
  ]
}
