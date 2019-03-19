"""
train.py
"""
import argparse
import numpy as np
import pandas
from sklearn.metrics import accuracy_score, f1_score, roc_auc_score
from sklearn.model_selection import train_test_split
import tensorflow as tf
import mlflow
import mlflow.keras

def load_data(csv_file):
    """
    Load data with corresponding feature
    """
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

def neural_network_model(input_dim, nb_hidden_layers, layer_depth):
    """ 
    Neural network architecture
    """
    input_layer = [tf.keras.layers.Dense(layer_depth, input_dim=input_dim, activation='relu')]
    hidden_layers = [tf.keras.layers.Dense(layer_depth, activation='relu') for i in range(nb_hidden_layers)]
    output_layer = [tf.keras.layers.Dense(1, activation='sigmoid')]
    model = tf.keras.models.Sequential(input_layer + hidden_layers + output_layer)
    model.compile(loss='binary_crossentropy', optimizer='adam')
    return model

def eval_metrics(y_test, y_pred):
    """
    Compute metrics
    """
    f1 = f1_score(y_test, y_pred)
    accuracy = accuracy_score(y_test, y_pred)
    roc = roc_auc_score(y_test, y_pred)
    return f1, accuracy, roc

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--split_dataset_rate", default=0.3, type=float)
    parser.add_argument("--epochs", default=10, type=int)
    parser.add_argument("--nb_hidden_layers", default=3, type=int)
    parser.add_argument("--layer_depth", default=10, type=int)
    args = parser.parse_args()

    np.random.seed(8)
    tf.set_random_seed(8)
    data = load_data("model/expected_goal/resources/premier_league_shots.csv")
    x_train, y_train, x_test, y_test = split_dataset(data, args.split_dataset_rate, "is_goal")
    
    with mlflow.start_run():
        model = neural_network_model(x_train.shape[1], args.nb_hidden_layers, args.layer_depth)
        model.fit(x_train, y_train, epochs=args.epochs)
        y_pred = model.predict_classes(x_test)

        (f1, accuracy, roc) = eval_metrics(y_test, y_pred)
        mlflow.log_param("split_dataset_rate", args.split_dataset_rate)
        mlflow.log_param("epochs", args.epochs)
        mlflow.log_param("nb_hidden_layers", args.nb_hidden_layers)
        mlflow.log_param("layer_depth", args.layer_depth)
        mlflow.log_metric("f1_score", f1)
        mlflow.log_metric("accuracy_score", accuracy)
        mlflow.log_metric("roc_auc_score", roc)

        mlflow.keras.log_model(model, "expected_goal_model")

