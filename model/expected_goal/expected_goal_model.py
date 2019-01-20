"""
Expected Goal Model
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
from keras.models import Sequential, Model
from keras.layers import Input, Dense

def load_data(csv_file):
    data = pandas.read_csv(csv_file, sep=",")
    return data[["x_shot", "y_shot", "goal_distance", "big_chance", "is_goal"]]

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

def simple_neural_network(input_dim):
    """ 
    Simple neural net structure 
    """
    model = Sequential([
        Dense(100, input_dim=input_dim, activation='relu'),
        Dense(50, activation='relu'),
        Dense(50, activation='relu'),
        Dense(50, activation='relu'),
        Dense(25, activation='relu'),
        Dense(25, activation='relu'),
        Dense(1, activation='sigmoid')])
    model.compile(loss='binary_crossentropy', optimizer='adam')
    return model


if __name__ == "__main__":
    data = load_data("premier_league_shots.csv") # load training dataset
    x_train, y_train, x_test, y_test = split_dataset(data, 0.3, "is_goal")  # split data

    # model = RandomForestClassifier(n_estimators=100)
    model = simple_neural_network(4)
    model.fit(x_train, y_train, epochs=50)
    y_pred = model.predict_classes(x_test)
    print(classification_report(y_test, y_pred))

    joblib.dump(model, 'expected_goal/expected_goal_model.pkl')  # save model
