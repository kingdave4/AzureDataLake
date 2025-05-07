import logging
import os
import azure.functions as func  # type: ignore
from data_operations import fetch_nba_data, upload_to_blob_storage

def main(mytimer: func.TimerRequest):
    """
    Timer-triggered Azure Function to refresh the NBA Data Lake.
    """
    logging.info("NBA timer trigger function started...")

    vault = os.getenv("KEY_VAULT_NAME", "mydatalakekeyvault48")
    data = fetch_nba_data(vault, "SportsDataApiKey")

    if data:
        upload_to_blob_storage(vault, data)
        logging.info("Data lake refresh complete.")
    else:
        logging.warning("No data fetched; skipping upload.")
