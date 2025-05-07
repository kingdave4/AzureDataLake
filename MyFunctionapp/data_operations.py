import json
import os
import requests
from azure.identity import DefaultAzureCredential 
from azure.keyvault.secrets import SecretClient 
from azure.storage.blob import BlobServiceClient 
from requests.exceptions import RequestException
from azure.core.exceptions import AzureError



def _get_secret(vault_name: str, secret_name: str):
    """
    Retrieve a secret's value from Azure Key Vault.
    """
    kv_uri     = f"https://{vault_name}.vault.azure.net/"          
    credential = DefaultAzureCredential()                        
    client     = SecretClient(vault_url=kv_uri, credential=credential)
    return client.get_secret(secret_name).value              
     


def fetch_nba_data(vault_name: str, api_key_secret: str):
    """
    Fetch NBA player data using the API key stored in Key Vault.
    """
    nba_endpoint = os.getenv("NBA_ENDPOINT")
    try:
        api_key     = _get_secret(vault_name, "SportsDataApiKey")
        headers     = {"Ocp-Apim-Subscription-Key": api_key}
        resp        = requests.get(nba_endpoint, headers=headers, timeout=10)
        resp.raise_for_status() # Raise HTTPError for bad responses (4xx, 5xx)
        return resp.json()
    except RequestException as e:
        print(f"[ERROR] Fetching NBA data failed: {e}")
        return []



def upload_to_blob_storage(vault_name: str, data: list, container_name: str = "nba-datalake", blob_name: str = "raw-data/nba_player_data.jsonl"):
    """
    Upload NBA data to Azure Blob Storage using connection string from Key Vault.
    """
    try:
        conn_str = _get_secret(vault_name, "StorageConnectionString")
        client   = BlobServiceClient.from_connection_string(conn_str)  

        # Ensure container exists
        container = client.get_container_client(container_name)

        # Prepare and upload line‑delimited JSON
        payload   = "\n".join(json.dumps(rec) for rec in data)
        blob      = container.get_blob_client(blob_name)
        blob.upload_blob(payload, overwrite=True)
        print(f"[INFO] Uploaded {len(data)} records to {container_name}/{blob_name}")

    except AzureError as e:
        print(f"[ERROR] Upload to Blob Storage failed: {e}")
