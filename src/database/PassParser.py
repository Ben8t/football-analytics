"""
Pass parser
Parse pass data
"""
import numpy
import hashlib


class PassParser():

    def __init__(self):
        pass
    
    @staticmethod
    def distance(x1, y1, x2, y2):
        if x1 is None or y1 is None:
            return None
        return numpy.sqrt( (x2 - x1)**2 + (y2 - y1)**2 )

    def get_pass(self, id, data):
        """
        Parse pass data
        :return response: a list of dict containing pass informations
        """
        response = []
        i = 0
        for event in data["events"]:
            processed_data = {}
            if "Pass" in event["type"]["displayName"]:
                clean_dict = {}
                for qualifier in event["qualifiers"]:
                    if "value" in qualifier:
                        clean_dict[qualifier["type"]["displayName"]] = qualifier["value"]
                    else:
                        clean_dict[qualifier["type"]["displayName"]] = qualifier["type"]["value"]
                processed_data["game_id"] = id
                processed_data["event_id"] = str(event["id"])
                processed_data["x_begin"] = 105*event["x"]/100
                processed_data["y_begin"] = 68*event["y"]/100
                processed_data["x_end"] = 105*float(clean_dict["PassEndX"])/100 if "PassEndX" in clean_dict else None
                processed_data["y_end"] = 68*float(clean_dict["PassEndY"])/100 if "PassEndY" in clean_dict else None
                processed_data["goal_distance"] = self.distance(processed_data["x_end"], processed_data["y_end"], 105, 34)
                processed_data["type_value"] = event["type"]["value"]
                processed_data["type_name"] = event["type"]["displayName"]
                processed_data["player_id"] = str(event["playerId"])
                processed_data["team_id"] = str(event["teamId"])
                is_assist = 0
                    if "IntentionalGoalAssist" in clean_dict:
                        is_assist = 1
                    elif data["events"][i+1]["type"]["displayName"] == "Goal":
                        is_assist = 1
                    else:
                        is_assist = 0
                processed_data["is_assist"] = is_assist
                processed_data["key_pass"] = 1 if "KeyPass" in clean_dict else 0
                processed_data["big_chance_created"] = 1 if "BigChanceCreated" in clean_dict else 0
                response.append(processed_data)
            i = i + 1
        return response