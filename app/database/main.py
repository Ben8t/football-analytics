import json
from src.database.WhoScoredToDataBase import WhoScoredToDataBase


if __name__ == "__main__":
    files = [
        "data/England-Premier-League-2015-2016-Arsenal-Crystal-Palace.json",
        "data/England-Premier-League-2015-2016-Arsenal-Watford.json"
    ]

    config = json.load(open("app/database/config.json"))
    wsdb = WhoScoredToDataBase(config["database"], config["host"], config["user"], config["password"])
    for file in files:
        wsdb.process_file(file)
    wsdb.close_connection()
    


