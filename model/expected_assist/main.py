"""
Expected assist model application
Compute xA for pass data

Usage :
python3 -m model.expected_assist.main "/Users/username/folder/data.csv"

Wildcard:
-s input for saving file

"""
import argparse
import numpy as np
import pandas
from sklearn.externals import joblib

def model_application(model, pass_data):
    """
    Return Expected assist for every pass
    """
    pass_data = pass_data.replace([np.inf, -np.inf], np.nan).dropna()
    y_pred = model.predict_proba(pass_data[["x_begin", "y_begin", "x_end", "y_end", "goal_distance", "key_pass", "big_chance_created"]])
    pass_data["xA"] = [y[1] for y in y_pred]
    return pass_data

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("data", help="csv file containing pass data")
    parser.add_argument("-s", "--save", help="input for saving file", action="store_true")
    args = parser.parse_args()

    model = joblib.load("model/expected_assist/expected_assist_model.pkl")
    pass_data = pandas.read_csv(args.data)

    xA = model_application(model, pass_data)
    print(xA[xA["xA"]>0.05])

    # Saving option
    if args.save:
            file_path = input("File path (for example /Users/username/folder/file.csv): ")
            xA.to_csv(file_path, index=False)


