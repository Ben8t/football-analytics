"""
Expected Assist Model
"""

import numpy as np
import pandas
from sklearn.metrics import accuracy_score, confusion_matrix, f1_score, classification_report
from sklearn.metrics import mean_squared_error
from sklearn.pipeline import Pipeline, FeatureUnion, make_pipeline, make_union, clone
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import GridSearchCV
from sklearn.model_selection import train_test_split
from sklearn.externals import joblib

def load_data(csv_file):
    data = pandas.read_csv(csv_file, sep=",").dropna(axis=0)
    return data[["x_begin", "y_begin", "x_end", "y_end", "goal_distance", "key_pass", "big_chance_created", "is_assist"]]

def split_dataset(data, split_rate, output_variable):
    """
    Split dataset in 4 parts : x_train, y_train, x_test, y_test.
    :param data: pandas dataframe
    :param split_rate: often 0.3
    :param output_variable: variable to predict
    :return: x_train, y_train, x_test, y_test (pandas dataframes)
    """
    train_set, test_set = train_test_split(data, test_size=split_rate, random_state=0)
    x_train = train_set.drop(output_variable, axis=1)
    y_train = train_set[output_variable]
    x_test = test_set.drop(output_variable, axis=1)
    y_test = test_set[output_variable]
    return x_train, y_train, x_test, y_test



if __name__ == "__main__":
    data = load_data("model/expected_assist/resources/premier_league_pass.csv") # load training dataset
    x_train, y_train, x_test, y_test = split_dataset(data, 0.3, "is_assist")  # split data

    model = RandomForestClassifier(n_estimators=100)
    model.fit(x_train, y_train)
    y_pred = model.predict(x_test)
    print(classification_report(y_test, y_pred))

    joblib.dump(model, 'model/expected_assist/resources/model.pkl')  # save model
