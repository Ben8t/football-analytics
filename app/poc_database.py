import json
from src.database.WhoScoredToDataBase import WhoScoredToDataBase


if __name__ == "__main__":
    wsdb = WhoScoredToDataBase("postgres", "localhost", "postgres", "pgpass")
    wsdb.process_file("data/England-Premier-League-2015-2016-Aston-Villa-Liverpool.json")


