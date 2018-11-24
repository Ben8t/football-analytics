import json
import argparse
import glob 
from src.database.WhoScoredToDataBase import WhoScoredToDataBase
from src.crawler.WhoScoredCrawler import WhoScoredCrawler


if __name__ == "__main__":
    # parser = argparse.ArgumentParser()
    # parser.add_argument("url", help="WhoScored URL")
    # args = parser.parse_args()
    
    # config = json.load(open("app/ingest/config.json"))
    # crawler = WhoScoredCrawler()
    # wsdb = WhoScoredToDataBase(config["database"], config["host"], config["user"], config["password"])

    # file = crawler.crawl(args.url)
    # wsdb.process_file(file)
    # wsdb.close_connection()

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
    


