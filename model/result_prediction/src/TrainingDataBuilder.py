"""TrainingDataBuilder.py"""
import psycopg2
import psycopg2.extras
import pandas


class TrainingDataBuilder:
    """A class to build training data

    Attributes:
        database_config (dict): Database configuration
        query_path (str): Queries folder path
        expected_goal_model (keras.model): Loaded expected goal model
    """
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
        """Gather past scored goals for a team

        Args:
            date (str): Date
            team_id (str): A team id
            past_offset (int): Time lag to watch
        
        Returns:
            list: list of scored goals
        """
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
        """Gather past conceded goals for a team

        Args:
            date (str): Date
            team_id (str): A team id
            past_offset (int): Time lag to watch
        
        Returns:
            list: list of conceded goals
        """
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
        """Gather past expected goals for a team

        Args:
            date (str): Date
            team_id (str): A team id
            past_offset (int): Time lag to watch
        
        Returns:
            list: list of expected_goals
        """
        sql_query_file = self.__query_path + "/get_shots.sql"
        with open(sql_query_file) as sql_query:
            query = sql_query.read().format(
                date=date,
                team_id=team_id,
                past_offset=past_offset
            )
        self.__cursor.execute(query)
        results = [dict(result) for result in self.__cursor.fetchall()]
        shots_dataframe = pandas.DataFrame(results)
        prediction = self.__expected_goal_model.predict_proba(shots_dataframe[["x_shot", "y_shot", "goal_distance", "big_chance"]])
        shots_dataframe["xG"] = [y[0] for y in prediction]
        result = shots_dataframe.groupby("startDate").sum()["xG"]
        return result.tolist()

    def get_features(self, date, team_id, past_offset=5):
        """Gather all features in one place

        Args:
            date (str): Date
            team_id (str): A team id
            past_offset (int): Time lag to watch
        
        Returns:
            dict: features
        """
        result = {}
        feature_names = ["scored_goals", "conceded_goals", "expected_goals"]
        scored_goals = self.get_scored_goals(date, team_id, past_offset)
        conceded_goals = self.get_conceded_goals(date, team_id, past_offset)
        expected_goals = self.get_expected_goals(date, team_id, past_offset)
        features = [scored_goals, conceded_goals, expected_goals]
        for i in [0, 1, 2]:
            for jr in range(past_offset):
                result[feature_names[i]+f"_{jr}"] = features[i][jr]
        return result

    def build_training_data(self):
        """Build training data
        This function helps to build training data according to a list
        of games (with date, home_team_id, away_team_id)
        
        Returns:
            pandas.DataFrame: All data with built features
        """
        sql_query_file = self.__query_path + "/get_games.sql"
        with open(sql_query_file) as sql_query:
            query = sql_query.read()
        self.__cursor.execute(query)
        results = pandas.DataFrame([dict(result) for result in self.__cursor.fetchall()])
        features_data = []
        for index, row in results.iterrows():
            try:
                features = {}
                home_features = self.get_features(row["startDate"], row["home_team_id"], 5)
                home_features = {f'home_{k}': v for k, v in home_features.items()}  # add "home" suffix
                away_features = self.get_features(row["startDate"], row["away_team_id"], 5)
                away_features = {f'away_{k}': v for k, v in away_features.items()}  # add "away" suffix
                features.update(home_features)
                features.update(away_features)
                features["game_id"] = row["game_id"]
                features_data.append(features)
            except:
                pass
        
        features_dataframe = pandas.DataFrame(features_data)
        full_data = pandas.merge(results, features_dataframe, on='game_id', how='inner')  # inner join base data with built features
        return full_data