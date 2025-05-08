import os
from azure.identity import DefaultAzureCredential
from azure.keyvault.secrets import SecretClient
from data_operations import fetch_nba_data, upload_to_blob_storage


# This script fetches NBA data from the SportsData API and uploads it to Azure Blob Storage.
def main():
    vault_name = os.getenv("KEY_VAULT_NAME", "mydatalakekeyvault48")
    kv_uri     = f"https://{vault_name}.vault.azure.net/"
    credential = DefaultAzureCredential()                                     
    kv_client  = SecretClient(vault_url=kv_uri, credential=credential)

    conn_str = kv_client.get_secret("StorageConnectionString").value           
    api_key  = kv_client.get_secret("SportsDataApiKey").value

    data = fetch_nba_data(api_key=api_key)
    if data:
        upload_to_blob_storage(data, conn_str)
        print("Data lake refresh complete.")
    else:
        print("No data fetched; nothing uploaded.")

if __name__ == "__main__":
    main()

