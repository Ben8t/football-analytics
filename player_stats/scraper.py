import glob
import json
import pandas as pd

list_files = glob.glob("./data/*.json")

json_data = [json.load(open(f)) for f in list_files]

print(json_data[0]['entity']['name']['display'])

data = [[elm['entity']['name']['first'],elm['entity']['name']['last']] for elm in json_data]

print(data)

df = pd.DataFrame(data)
df.columns = ["first","name"]

print(df)
