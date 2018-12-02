"""
WhoScoredToDataBase.py
Connector to transform WhoScored (Opta) data to relational database
"""
import json
import hashlib
import psycopg2
from psycopg2.extensions import AsIs
from src.database.ShotParser import ShotParser
from src.database.PassParser import PassParser

class WhoScoredToDataBase():

    def __init__(self, database, host, user, password):
        """
        :param database: database name
        :param host: host name
        :param user: user name for database connection
        :param password: password
        """
        self.__connection = psycopg2.connect(database=database, user=user, host=host, password=password)
        self.__cursor = self.__connection.cursor()

    def process_file(self, file):
        """
        Process a file and store data to the database
        :param file: a json file containing data
        """
        data = json.load(open(file))
        id = hashlib.md5(data["timeStamp"].encode("utf-8")).hexdigest()  # create a unique game id based on timeStamp
        self.__insert_metadata(id, data)
        self.__insert_player_dictionnary(id, data)
        self.__insert_events(id, data)
        self.__insert_event_shots(id, data)
        self.__insert_event_pass(id, data)
        self.__connection.commit()

    def __insert_metadata(self, id, data):
        """
        Gather and insert metadata to the database
        :param id: unique game id
        :param data: loaded data
        """
        values = []
        columns = []
        for key, value in data.items():
            if type(data[key]) == str or type(data[key]) == int:
                values.append(value)
                columns.append('"' + key + '"')
        columns.append("game_id")
        values.append(id)

        home_score = int(data["ftScore"][0])
        away_score = int(data["ftScore"][4])
        if home_score > away_score:
            result = "home"
        elif home_score < away_score:
            result = "away"
        else:
            result = "draw"
        columns.extend([
            "home_team_id", 
            "home_team_name", 
            "home_manager_name", 
            "home_formation", 
            "away_team_id", 
            "away_team_name", 
            "away_manager_name",
            "away_formation",
            "home_score",
            "away_score",
            "result"
        ])
        values.extend([
            data["home"]["teamId"], 
            data["home"]["name"], 
            data["home"]["managerName"], 
            data["home"]["formations"][0]["formationName"], 
            data["away"]["teamId"], 
            data["away"]["name"], 
            data["away"]["managerName"],
            data["away"]["formations"][0]["formationName"],
            home_score,
            away_score,
            result
        ])
        insert_statement = "INSERT INTO public.metadata (%s) VALUES %s"
        # print(self.__cursor.mogrify(insert_statement, (AsIs(','.join(columns)), tuple(values))))
        self.__cursor.execute(insert_statement, (AsIs(','.join(columns)), tuple(values)))
        
    def __insert_player_dictionnary(self, id, data):
        """
        Gather and insert player information
        :param id: unique game id
        :param data: loaded data
        """
        values = []
        for field in ["home", "away"]:
            for player in data[field]["players"]:
                values.append((
                    id,
                    field, 
                    data[field]["teamId"],
                    player["playerId"],
                    player["name"],
                    player["position"],
                    player["height"],
                    player["weight"],
                    player["age"])
                )
        args_str = ','.join(self.__cursor.mogrify("(%s,%s,%s,%s,%s,%s,%s,%s,%s)", x).decode('utf-8') for x in values)
        self.__cursor.execute("INSERT INTO public.player_base (game_id, field, team_id, player_id, player_name, player_position, player_height, player_weight, player_age) VALUES " + args_str) 

    def __insert_events(self, id, data):
        values = []
        for event in data["events"]:
            values.append((
                id,
                str(event["id"]),
                event.get("minute", None),
                event.get("second", None),
                event.get("teamId", None),
                event.get("playerId", None),
                105*event.get("x", None)/100,
                68*event.get("y", None)/100,
                event["type"]["value"],
                event["type"]["displayName"],
                event["outcomeType"]["value"],
                event["outcomeType"]["displayName"],
                int(event.get("isTouch", None))
            ))
        args_str = ','.join(self.__cursor.mogrify("(%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)", x).decode('utf-8') for x in values)
        self.__cursor.execute("INSERT INTO public.events (game_id, event_id, minute, second, team_id, player_id, x, y, type_value, type_name, outcome_type_value, outcome_type_name, is_touch) VALUES " + args_str) 

    def __insert_event_shots(self, id, data):
        shot_parser = ShotParser()
        processed_data = shot_parser.get_shots(id, data)
        for event in processed_data:
            values = []
            columns = []
            for key, value in event.items():
                values.append(value)
                columns.append('"' + key + '"')
            insert_statement = "INSERT INTO public.event_shots (%s) VALUES %s"
            self.__cursor.execute(insert_statement, (AsIs(','.join(columns)), tuple(values)))
        
    def __insert_event_pass(self, id, data):
        pass_parser = PassParser()
        processed_data = pass_parser.get_pass(id, data)
        for event in processed_data:
            values = []
            columns = []
            for key, value in event.items():
                values.append(value)
                columns.append('"' + key + '"')
            insert_statement = "INSERT INTO public.event_pass (%s) VALUES %s"
            self.__cursor.execute(insert_statement, (AsIs(','.join(columns)), tuple(values)))
        

    def close_connection(self):
        self.__cursor.close()
        self.__connection.close()