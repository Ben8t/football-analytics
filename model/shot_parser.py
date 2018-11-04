"""
Shot parser
"""

import os
import glob
import json
import numpy
import pandas



class ShotParser():

    def __init__(self, files):
        """
        :param: a list of json files
        """
        self.__files = files

    def load_data(self, file):
        """
        Load data from file
        """
        with open(file) as fopen:
            data = json.load(fopen)
        return data

    @staticmethod
    def distance(x1, y1, x2, y2):
        return numpy.sqrt( (x2 - x1)**2 + (y2 - y1)**2 )

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
        """
        Parse shots data for every file and then agregate
        :return response: a list of dict containing shots informations
        """
        response = []
        for file in self.__files:
            data = self.load_data(file)
            print("Processing ", file)
            for event in data["events"]:
                processed_data = {}
                if "Shot" in event["type"]["displayName"] or "Goal" in event["type"]["displayName"]:
                    processed_data["id"] = str(event["id"])
                    processed_data["x_shot"] = 105*event["x"]/100
                    processed_data["y_shot"] = 68*event["y"]/100
                    processed_data["goal_distance"] = self.distance(processed_data["x_shot"], processed_data["y_shot"], 105, 34)
                    processed_data["value"] = event["type"]["value"]
                    processed_data["name"] = event["type"]["displayName"]
                    processed_data["player_name"] = self.get_player_name(data, str(event["playerId"]))
                    processed_data["team_name"] = self.get_team(data, event["playerId"])
                    processed_data["is_goal"] = 1 if event["type"]["value"] == 16 and processed_data["goal_distance"] < 60 else 0
                    processed_data["big_chance"] = 1 if 214 in [i["type"]["value"] for i in event["qualifiers"]] else 0
                    response.append(processed_data)
        return pandas.DataFrame(response)



if __name__ == "__main__":
    data_list = glob.glob("/Users/ben/Downloads/pl_data/*.json")
    shot_parser = ShotParser(data_list)
    processed_data = shot_parser.get_shots()
    processed_data.to_csv("premier_league_shots.csv", index=False)




