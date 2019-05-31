import psycopg2
import psycopg2.extras
import pandas

class TrainingDataBuilder:

    def __init__(self, database_config, query_path, expected_goal_model):
        self.__query_path = query_path
        self.__expected_goal_model = expected_goal_model
        self.__connection = psycopg2.connect(database=database_config["database"], 
            user=database_config["user"], 
            host=database_config["host"], 
            password=database_config["password"]
        )
        self.__cursor = self.__connection.cursor(cursor_factory=psycopg2.extras.DictCursor)

    def get_scored_goals(self, date, team_id, past_offset=5):
        sql_query_file = self.__query_path + "/get_scored_goals.sql"
        with open(sql_query_file) as sql_query:
            query = sql_query.read().format(
                date=date,
                team_id=team_id,
                past_offset=past_offset
            )
        self.__cursor.execute(query)
        results = self.__cursor.fetchall()
        return [result[0] for result in results]

    def get_conceded_goals(self, date, team_id, past_offset=5):
        sql_query_file = self.__query_path + "/get_conceded_goals.sql"
        with open(sql_query_file) as sql_query:
            query = sql_query.read().format(
                date=date,
                team_id=team_id,
                past_offset=past_offset
            )
        self.__cursor.execute(query)
        results = self.__cursor.fetchall()
        return [result[0] for result in results]

    def get_expected_goals(self, date, team_id, past_offset=5):
        sql_query_file = self.__query_path + "/get_shots.sql"
        with open(sql_query_file) as sql_query:
            query = sql_query.read().format(
                date=date,
                team_id=team_id,
                past_offset=past_offset
            )
        self.__cursor.execute(query)
        results = [dict(result) for result in self.__cursor.fetchall()]
        shots_data = pandas.DataFrame(results)
        prediction = self.__expected_goal_model.predict_proba(shots_data[["x_shot", "y_shot", "goal_distance", "big_chance"]])
        shots_data["xG"] = [y[0] for y in prediction]
        response = shots_data.groupby("startDate").sum()["xG"]
        return response.tolist()

    def get_features(self, date, team_id, past_offset=5):
        response = {}
        feature_names = ["scored_goals", "conceded_goals", "expected_goals"]
        scored_goals = self.get_scored_goals(date, team_id, past_offset)
        conceded_goals = self.get_conceded_goals(date, team_id, past_offset)
        expected_goals = self.get_expected_goals(date, team_id, past_offset)
        features = [scored_goals, conceded_goals, expected_goals]
        for i in [0, 1, 2]:
            for jr in range(past_offset):
                response[feature_names[i]+f"_{jr}"] = features[i][jr]
        return response