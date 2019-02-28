"""
Expected goal model application
Compute xG for shots data

Usage :
python -m model.expected_goal.main <shots_data_file.csv>

Wildcard:
-s input for saving file

"""
import argparse
import pandas
from sklearn.externals import joblib
from keras.models import load_model


def model_application(model, shots_data):
    """
    Return Expected goal for every shot
    """
    y_pred = model.predict_proba(shots_data[["x_shot", "y_shot", "goal_distance", "big_chance"]])
    shots_data["xG"] = [y[0] for y in y_pred]
    return shots_data

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("data", help="csv file containing shots data")
    parser.add_argument("-s", "--save", help="input for saving file", action="store_true")
    args = parser.parse_args()

    model = load_model('model/expected_goal/resources/dnn_model.h5')
    shots_data = pandas.read_csv(args.data)
    xG = model_application(model, shots_data)
    

    # Saving option
    if args.save:
            file_path = input("File path (for example /Users/username/folder/file.csv): ")
            xG.to_csv(file_path, index=False)


