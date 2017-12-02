# model1.py

from data_processing import *
import numpy as np
import pandas as pd
np.random.seed(1337)

from sklearn import preprocessing
from sklearn.ensemble import RandomForestClassifier

# Load datasets
E1415 = pd.read_csv('data/E1415.csv')
E1516 = pd.read_csv('data/E1516.csv')
E1617 = pd.read_csv('data/E1617.csv')
E1718 = pd.read_csv('data/E1718test.csv')

# Concat dataset
frames = [E1415,E1516,E1617,E1718]
data = pd.concat(frames)

# Processing data
processed_data=data_processing1(data)

# Modelisation
data_model = processed_data.head(processed_data.shape[0]-E1718.shape[0]) # remove 2017/2018 data, used later for testing

x_train,y_train,x_test,y_test = split_dataset(data_model,0.3,['FTR_A','FTR_D','FTR_H'])

# Normalization
x_train = preprocessing.scale(x_train.values)
x_test = preprocessing.scale(x_test.values)

# Keras neural network
model = RandomForestClassifier(n_estimators=75,min_samples_split=2,random_state=0)
model.fit(x_train,y_train.values)

score = model.score(x_test,y_test.values)
print("Validation Score : ",score)


# Final test
data_test = processed_data.tail(E1718.shape[0])
x_final_test = data_test.drop(['FTR_A','FTR_D','FTR_H'],axis=1)
x_final_test = preprocessing.scale(x_final_test.values)
y_final_test = data_test[['FTR_A','FTR_D','FTR_H']]

score = model.score(x_final_test,y_final_test.values)
print("Final Test Score : ",score)
