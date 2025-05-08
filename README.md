# Azure Data Lake Deployment and Refresh

**Repository:** https://github.com/kingdave4/AzureDataLake.git

## Overview

This project automates provisioning of an Azure Data Lake environment and schedules periodic refreshes of NBA data into the lake. Using Terraform for IaC, it creates Azure resources (Resource Group, Storage Account, Data Lake Gen2, Synapse Workspace, Key Vault, Function App, monitoring components), while an Azure Function fetches NBA data and uploads it to Blob Storage on a timer.

### Key Components

- **Terraform**: Infrastructure-as-code for Azure resources.
- **Azure Data Lake Gen2**: Hierarchical namespace–enabled storage for analytics.
- **Azure Synapse Workspace**: SQL analytics bound to the Data Lake.
- **Azure Key Vault**: Secure secret storage.
- **Azure Function (Python)**: Timer-triggered job to ingest NBA data.
- **Monitoring**: Application Insights and Log Analytics for telemetry.

## Prerequisites

- Azure Subscription with contributor permissions
- Terraform v1.0+ and AzureRM provider v3.100.0+
- Azure CLI configured to target your subscription
- Python 3.9+ for local testing
- Git for cloning the repo

## Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/kingdave4/AzureDataLake.git
   cd AzureDataLake
   ```

2. **Configure variables**
   Create a `secrets.tfvars` file with:
   ```hcl
   subscription_id    = "<YOUR_SUB_ID>"
   sql_admin_password = "<YOUR_SQL_PASSWORD>"
   apikey             = "<SPORTSDATA_API_KEY>"
   nba_endpoint       = "<NBA_API_ENDPOINT>"
   sp_object_id       = "<TERRAFORM_SP_OBJECT_ID>"
   ```

## Deployment

### Via Command Line
From the root of the repo, initialize and apply Terraform to provision infra:
```bash
terraform init
terraform plan -var-file="secrets.tfvars"
terraform apply -var-file="secrets.tfvars" -auto-approve
```

Navigate into the Function App project folder (`myfunctionapp`) and publish the Azure Function:
```bash
cd myfunctionapp
func azure functionapp publish datafunctionapp54
```

### Via Visual Studio / VS Code
1. Open the `myfunctionapp` folder in VS Code or Visual Studio.
2. Install and sign in with the Azure Functions extension.
3. Right-click the function project and select **Deploy to Function App**.

## Terraform Modules and Variables

Terraform configuration lives in `main.tf` and `variables.tf`:

- **Resource Group**: `azurerm_resource_group.rg`
- **Storage & Gen2**: `azurerm_storage_account.ST`, `azurerm_storage_data_lake_gen2_filesystem.fs`
- **Container**: `azurerm_storage_container.container`
- **Synapse**: `azurerm_synapse_workspace.syn`
- **Key Vault & Secrets**: `azurerm_key_vault.kv`, `azurerm_key_vault_secret.*`
- **Function App Plan & App**: `azurerm_service_plan.func_plan`, `azurerm_linux_function_app.nba_refresh`
- **Monitoring**: `azurerm_log_analytics_workspace.la`, `azurerm_application_insights.ai`, `azurerm_monitor_diagnostic_setting.func_diagnostics`

### Sample Variables (`variables.tf`)
```hcl
variable "resource_group_name" { default = "AzureDatalake-RG" }
variable "location"            { default = "East US 2" }
# ... see file for all variables
```

## Azure Function: Refresh Logic

The Function is in Python and triggered every 10 minutes (`"0 */10 * * * *"` in `function.json`).

### Entry Point (`__init__.py`)
```python
import logging, os
import azure.functions as func
from data_operations import fetch_nba_data, upload_to_blob_storage

def main(mytimer: func.TimerRequest):
    logging.info("NBA timer trigger function started...")
    vault = os.getenv("KEY_VAULT_NAME")
    data = fetch_nba_data(vault, "SportsDataApiKey")
    if data:
        upload_to_blob_storage(vault, data)
        logging.info("Data lake refresh complete.")
    else:
        logging.warning("No data fetched; skipping upload.")
```

### Data Operations (`data_operations.py`)
- **Secret Retrieval:** `DefaultAzureCredential` + `SecretClient`
- **API Call:** GET to `NBA_ENDPOINT` with header `Ocp-Apim-Subscription-Key`
- **Blob Upload:** Line-delimited JSON to `nba-datalake` container

## Monitoring and Logging

- **Live Logs:** `func azure functionapp log stream --name datafunctionapp54`
- **Application Insights:** Metrics and traces in Azure Portal under the Function’s AI resource

## Cleanup

To tear down all resources:
```bash
terraform destroy -var-file="secrets.tfvars" -auto-approve
```

## Contributing

1. Fork the repo
2. Create a feature branch
3. Open a pull request

## License

MIT © Kingdave4
