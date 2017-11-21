# model.py

from data_processing import *
import pandas as pd

# Load datasets
E1415 = pd.read_csv('data/E1415.csv')
E1516 = pd.read_csv('data/E1516.csv')
E1617 = pd.read_csv('data/E1617.csv')
E1718 = pd.read_csv('data/E1718test.csv')

# Concat dataset
frames = [E1415,E1516,E1617,E1718]
data = pd.concat(frames)[['Date','HomeTeam','AwayTeam','FTR','FTHG','FTAG','Referee','B365H','B365D','B365A']]

# Processing data
processed_data=data_processing(data)

# Modelisation
data_model = processed_data.head(processed_data.shape[0]-E1718.shape[0]) # remove 2017/2018 data, used later for testing