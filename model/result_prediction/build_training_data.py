import json
from keras.models import load_model
from model.result_prediction.src.TrainingDataBuilder import TrainingDataBuilder


if __name__ == "__main__":
    with open("model/result_prediction/config/database.json") as database_configuration_file:
        database_config = json.load(database_configuration_file)

    model = load_model('mlruns/0/0585a82ef79e4f84ba23320fbf2a87cf/artifacts/expected_goal_model/model.h5')
    
    training_data_builder = TrainingDataBuilder(database_config, "model/result_prediction/src/sql_queries", model)
    
    training_data = training_data_builder.build_training_data()
    training_data.to_csv("model/result_prediction/data/training_data.csv")