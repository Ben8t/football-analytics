
import numpy as np
import pandas as pd
import tensorflow as tf

LABELS = ["home", "draw", "away"]
LABEL = "result"
DROP_COLUMNS = ["game_id", "startDate"]

def get_dataset(file_path):
    # CSV columns in the input file.
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

def process_categorical_data(data, categories):
    pass

def gather_categorical_data(dataframe):
    pass

if __name__ == "__main__":
    train_set_file = "model/result_prediction/data/train_set.csv"   
    train_set = get_dataset(train_set_file)
    import ipdb; ipdb.set_trace()