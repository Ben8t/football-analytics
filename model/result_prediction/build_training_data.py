import json
from sklearn.model_selection import train_test_split
import tensorflow as tf
from model.result_prediction.src.TrainingDataBuilder import TrainingDataBuilder


if __name__ == "__main__":
    with open("model/result_prediction/config/database.json") as database_configuration_file:
        database_config = json.load(database_configuration_file)

    model = tf.keras.models.load_model('mlruns/0/0585a82ef79e4f84ba23320fbf2a87cf/artifacts/expected_goal_model/model.h5')
    
    training_data_builder = TrainingDataBuilder(database_config, "model/result_prediction/src/sql_queries", model)
    
    data = training_data_builder.build_training_data()

    train_set, test_set = train_test_split(data, test_size=0.2, random_state=42)
    train_set.to_csv("model/result_prediction/data/train_set.csv", index=False)
    test_set.to_csv("model/result_prediction/data/test_set.csv", index=False)