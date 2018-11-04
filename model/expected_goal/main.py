"""
Expected goal model application
Usage:
python3 -m expected_goal.main "/Users/username/folder/data.json"
python3 -m expected_goal.main "/Users/username/folder/"
python3 -m expected_goal.main "/Users/username/folder/*pattern*"

Wildcard:
-s input for saving file

"""
import sys
import glob
from shot_parser import ShotParser
from sklearn.externals import joblib

def model_application(model, shots_data):
    """
    Return Expected goal for every shot
    """
    y_pred = model.predict_proba(shots_data[["x_shot", "y_shot", "goal_distance", "big_chance"]])
    shots_data["xG"] = [y[1] for y in y_pred]
    return shots_data

if __name__ == "__main__":
    args = sys.argv
    files_input = args[1]
    if files_input.endswith(".json"): # a simple json file
        files = [files_input]
    elif files_input.endswith("/"): # for many files into one folder
        files = glob.glob(files_input)
    elif "*" in files_input: # for specific pattern (for example *Liverpool* for every Liverpool game)
        files = glob.glob(files_input)
    else:
        raise Exception("Bad argument, need a file (json) or a folder.")

    # loading shot paresr and model
    shot_parser = ShotParser(files)
    model = joblib.load("expected_goal/expected_goal_model.pkl")

    shots_data = shot_parser.get_shots()

    xG = model_application(model, shots_data)
    print(xG)

    # Saving option
    if len(args) > 2:
        if args[2] == "-s":
            file_path = input("File path (for example /Users/username/folder/file.csv): ")
            xG.to_csv(file_path, index=False)


