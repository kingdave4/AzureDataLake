data "azurerm_subscription" "primary" {}

data "azurerm_role_definition" "github_ci_cd" {
  name        = "GitHub-CICD-Terraform-Role"
  scope       = data.azurerm_subscription.primary.id
}
