"""
Shot parser
"""

import json
import pandas

class ShotParser():

    def __init__(self, files):
        self.__files = files

    def load_data(self, file):
        """
        Load data from file
        """
        with open(file) as fopen:
            data = json.load(fopen)
        return data

    @staticmethod
    def get_team(data, player_id):
        home_players_id = [player["playerId"] for player in data["home"]["players"]]
        away_players_id = [player["playerId"] for player in data["away"]["players"]]
        if player_id in home_players_id:
            return data["home"]["name"]
        if player_id in away_players_id:
            return data["away"]["name"]
        return None

    @staticmethod
    def get_player_name(data, player_id):
        return data["playerIdNameDictionary"][player_id]

    def get_shots(self):
        response = []
        for file in self.__files:
            data = self.load_data(file)
            for event in data["events"]:
                processed_data = {}
                if "Shot" in event["type"]["displayName"] or "Goal" in event["type"]["displayName"]:
                    processed_data["id"] = str(event["id"])
                    processed_data["x"] = event["x"]
                    processed_data["y"] = event["y"]
                    processed_data["value"] = event["type"]["value"]
                    processed_data["name"] = event["type"]["displayName"]
                    processed_data["player_name"] = self.get_player_name(data, str(event["playerId"]))
                    processed_data["team_name"] = self.get_team(data, event["playerId"])
                    response.append(processed_data)
        return response



if __name__ == "__main__":
    shot_parser = ShotParser([
        "/Users/ben/Documents/DevData/passnetwork/data/England-Premier-League-2018-2019-Arsenal-Everton/data.json",
        "/Users/ben/Documents/DevData/passnetwork/data/England-Premier-League-2018-2019-Arsenal-Leicester/data.json"])
    processed_data = pandas.DataFrame(shot_parser.get_shots())
    processed_data.to_csv("premier_league_shots.csv")




