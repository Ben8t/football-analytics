# model.py

from data_processing import *
import numpy as np
import pandas as pd
from keras.models import Sequential
from keras.layers import Dense,Dropout

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

# Keras neural network
model = Sequential()
model.add(Dense(200, input_dim=x_train.shape[1], activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(500, activation='relu'))
model.add(Dense(1000, activation='relu'))
model.add(Dense(500, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(500, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(500, activation='relu'))
model.add(Dense(500, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(250, activation='relu'))
model.add(Dense(250, activation='relu'))
model.add(Dropout(0.5))
model.add(Dense(200, activation='relu'))
model.add(Dense(200, activation='relu'))
model.add(Dense(3,activation='softmax'))

model.compile(loss='categorical_crossentropy', optimizer='adam', metrics=['accuracy'])

model.fit(x_train.values,y_train.values, epochs=20, batch_size=10)