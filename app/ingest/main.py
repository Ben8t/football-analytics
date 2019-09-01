"""
main.py

Ingest WhoScored data into Postgres database
Example:
python -m app.ingest.main -u <WhoScored URL> -c <CSV file with a list of WhoScored URL>
"""

import json
import argparse
import glob 
import time
from src.database.WhoScoredToDataBase import WhoScoredToDataBase
from src.crawler.WhoScoredCrawler import WhoScoredCrawler


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-u", "--url", type=str, help="WhoScored URL")
    parser.add_argument("-c", "--csv", type=str, help="CSV file with a list of WhoScored URL")
    args = parser.parse_args()
    
    config = json.load(open("app/ingest/config.json"))
    crawler = WhoScoredCrawler()
    wsdb = WhoScoredToDataBase(config["database"], config["host"], config["user"], config["password"])

    if args.url:
        file = crawler.crawl(args.url)
        wsdb.process_file(file)
        wsdb.close_connection()
    elif args.csv:
        with open(args.csv, "r") as urls:
            for url in urls.readlines():
                for i in range(5):
                    try:
                        file = crawler.crawl(url)
                    except Exception as e:
                        print(e)
                if file:
                    wsdb.process_file(file)
                    time.sleep(20)
            crawler.close()
            wsdb.close_connection()

    else:
        print("No argument")

    


