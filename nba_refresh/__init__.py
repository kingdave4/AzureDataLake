import logging
import os
import azure.functions as func # type: ignore
from data_operations import fetch_nba_data, upload_to_blob_storage

def main(mytimer: func.TimerRequest):
    """
    Timer-triggered Azure Function to refresh the NBA Data Lake.
    """
    vault = os.getenv("KEY_VAULT_NAME", "mydatalakekeyvault9982")             
    data  = fetch_nba_data(vault, "SportsDataApiKey")
    if data:
        upload_to_blob_storage(vault, data)
        logging.info("Data lake refresh complete.")
    else:
        logging.warning("No data fetched; skip upload.")


