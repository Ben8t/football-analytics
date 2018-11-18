import json
import argparse
from src.database.WhoScoredToDataBase import WhoScoredToDataBase


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("file", help="file containing a list of data files to process in database")
    args = parser.parse_args()
    
    files = [line.rstrip('\n') for line in open(args.file)]
    config = json.load(open("app/database/config.json"))
    wsdb = WhoScoredToDataBase(config["database"], config["host"], config["user"], config["password"])
    for file in files:
        wsdb.process_file(file)
    wsdb.close_connection()
    


