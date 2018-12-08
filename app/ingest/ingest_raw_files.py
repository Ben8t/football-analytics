"""
ingest_raw_files.py

Ingest downloaded data into Postgres database
Example:
python -m app.ingest.ingest_raw_files.py (base folder is data/raw/)
"""

import json
import argparse
import glob 
from src.database.WhoScoredToDataBase import WhoScoredToDataBase
from src.crawler.WhoScoredCrawler import WhoScoredCrawler


if __name__ == "__main__":
    config = json.load(open("app/ingest/config.json"))
    wsdb = WhoScoredToDataBase(config["database"], config["host"], config["user"], config["password"])
    files = glob.glob("data/raw/*.json")
    i = 0
    for file in files:
        print("Processing : ", file)
        wsdb.process_file(file)
        i = i + 1
        if i % 25 == 0:
            print("Processing in progress: ", i*100/len(files)," %")

    wsdb.close_connection()
    


