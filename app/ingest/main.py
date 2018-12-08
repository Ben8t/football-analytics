"""
main.py

Ingest WhoScored data into Postgres database
Example:
python -m app.ingest.main <WhoScored URL>
"""

import json
import argparse
import glob 
from src.database.WhoScoredToDataBase import WhoScoredToDataBase
from src.crawler.WhoScoredCrawler import WhoScoredCrawler


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("url", help="WhoScored URL")
    args = parser.parse_args()
    
    config = json.load(open("app/ingest/config.json"))
    crawler = WhoScoredCrawler()
    wsdb = WhoScoredToDataBase(config["database"], config["host"], config["user"], config["password"])

    file = crawler.crawl(args.url)
    wsdb.process_file(file)
    wsdb.close_connection()
    


