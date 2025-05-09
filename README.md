# Azure Data Lake Deployment and Refresh

## Overview

This project automates the provisioning of an Azure Data Lake environment and schedules a periodic refresh of NBA data into the lake. We use Terraform for infrastructure-as-code to create Azure resources (Resource Group, Storage Account, Data Lake Gen2, Synapse Workspace, Key Vault, Function App, Monitor, and related components). An Azure Function, triggered on a timer, fetches NBA data from a configurable API and uploads it to Blob Storage.


### Key Components

- **Terraform**: Infrastructure-as-code that reliably provisions and configures Azure resources, ensuring consistency and repeatability.
- **Azure Data Lake Gen2**: Provides a high-performance, hierarchical namespace–enabled storage layer optimized for analytics workloads.
- **Azure Synapse Workspace**: Offers integrated analytics with both serverless SQL and Spark engines, enabling rapid querying of data stored in the Data Lake for BI and data science scenarios.
- **Azure Key Vault**: Centralizes and secures application secrets, connection strings, and certificates; integrates with managed identities to enforce least-privilege access without embedding sensitive values in code or Terraform state.
- **Azure Function (Python)**: Serverless compute that runs code on-demand, triggered by a timer for periodic data ingestion without managing servers.
- **Application Insights**: Provides deep monitoring, distributed tracing, and alerting for the Function App, helping diagnose performance issues and exceptions in real time.
- **Azure Monitor (Log Analytics)**: Collects, aggregates, and analyzes telemetry across resources; enables custom log queries and dashboards for long-term monitoring and operational insights.


## Architecture Diagram
![alt text](image-1.png)

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
