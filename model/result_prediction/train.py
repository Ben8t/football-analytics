
import numpy as np
import pandas as pd
import tensorflow as tf

LABELS = ["home", "draw", "away"]
LABEL = "result"
DROP_COLUMNS = ["game_id", "startDate"]

def get_dataset(file_path):
    with open(file_path, "r") as f:
        names_row = f.readline()
    csv_columns = names_row.rstrip("\n").split(",")
    columns_to_use = [col for col in csv_columns if col not in DROP_COLUMNS]
    dataset = tf.data.experimental.make_csv_dataset(
        file_path,
        batch_size=12,
        column_names=csv_columns,
        select_columns=columns_to_use, 
        label_name=LABEL,
        na_value="?",
        num_epochs=1,
        ignore_errors=True)
    return dataset

def numeric_features():
    feature_columns = []

    # numeric features
    for team_context in ["home", "away"]:
        for name in ["scored_goals", "conceded_goals", "expected_goals"]:
            for i in range(0,5):
                numeric_columns_name = f"{team_context}_{name}_{i}"
                feature_columns.append(tf.feature_column.numeric_column(numeric_columns_name))
    return feature_columns



if __name__ == "__main__":
    train_set_file = "model/result_prediction/data/train_set.csv"   
    train_set = get_dataset(train_set_file)
    test_set_file = "model/result_prediction/data/test_set.csv"   
    test_set = get_dataset(test_set_file)
    
    feature_columns = numeric_features()
    
    feature_layer = tf.keras.layers.DenseFeatures(feature_columns)

    model = tf.keras.Sequential([
        feature_layer,
        tf.keras.layers.Dense(64, activation='relu'),
        tf.keras.layers.Dense(64, activation='relu'),
        tf.keras.layers.Dense(64, activation='relu'),
        tf.keras.layers.Dense(64, activation='relu'),
        tf.keras.layers.Dense(64, activation='relu'),
        tf.keras.layers.Dense(3, activation='softmax')
    ])

    model.compile(optimizer='adam',
                loss='categorical_crossentropy',
                metrics=['accuracy'],
                run_eagerly=True)

    model.fit(train_set, epochs=100)

    loss, accuracy = model.evaluate(test_set)
    print("Accuracy", accuracy)