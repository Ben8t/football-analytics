"""
Shot parser
Parse shots data from a list of files
"""
import numpy
import hashlib


class ShotParser():

    def __init__(self):
        pass
    
    @staticmethod
    def distance(x1, y1, x2, y2):
        return numpy.sqrt( (x2 - x1)**2 + (y2 - y1)**2 )

    def get_shots(self, id, data):
        """
        Parse shots data
        :return response: a list of dict containing shots informations
        """
        response = []
        for event in data["events"]:
            processed_data = {}
            if "Shot" in event["type"]["displayName"] or "Goal" in event["type"]["displayName"]:
                processed_data["game_id"] = id
                processed_data["event_id"] = str(event["id"])
                processed_data["x_shot"] = 105*event["x"]/100
                processed_data["y_shot"] = 68*event["y"]/100
                processed_data["goal_distance"] = self.distance(processed_data["x_shot"], processed_data["y_shot"], 105, 34)
                processed_data["type_value"] = event["type"]["value"]
                processed_data["type_name"] = event["type"]["displayName"]
                processed_data["player_id"] = str(event["playerId"])
                processed_data["team_id"] = str(event["teamId"])
                processed_data["is_goal"] = 1 if event["type"]["value"] == 16 and processed_data["goal_distance"] < 60 else 0
                processed_data["big_chance"] = 1 if 214 in [i["type"]["value"] for i in event["qualifiers"]] else 0
                response.append(processed_data)
        return response