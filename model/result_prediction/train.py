"""train.py"""
import numpy as np
import pandas as pd
import mlflow
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score

np.random.seed(8)

def process_features(data):
    """Process and select features

    Args:
        data (pandas.DataFrame): Dataframe
    Returns:
        pandas.DataFrame: Dataframe with corresponding processed features
    """
    feature_columns = [feature for feature in list(data.columns) if "goals" in feature]
    return data[feature_columns]

def process_target(data):
    """Process target

    Args:
        data (pandas.DataFrame): Dataframe
    Returns:
        pandas.Series: Series with corresponding targets
    """
    return data["result"]

def split_feature_target(data):
    """Separate features and targets

    Args:
        data (pandas.DataFrame): Dataframe
    Returns:
        pandas.DataFrame: DataFrame corresponding to features
        pandas.DataFrame: DataFrame corresponding to targets
    """
    return process_features(data), process_target(data)

if __name__ == "__main__":
    train_set_file = "model/result_prediction/data/train_set.csv"   
    test_set_file = "model/result_prediction/data/test_set.csv"
    train_dataset = pd.read_csv(train_set_file)
    test_dataset = pd.read_csv(test_set_file)

    x_train, y_train = process_features(train_dataset), process_target(train_dataset)
    x_test, y_test = process_features(test_dataset), process_target(test_dataset) 

    with mlflow.start_run(run_name="result_prediction"):
        n_estimators = 1000
        model = RandomForestClassifier(n_estimators=n_estimators)
        model.fit(x_train, y_train)
        y_pred = model.predict(x_test)
        accuracy = accuracy_score(y_test, y_pred)

        mlflow.log_param("features", list(x_train.columns))
        mlflow.log_param("n_estimators", n_estimators)
        mlflow.log_metric("accuracy", accuracy)