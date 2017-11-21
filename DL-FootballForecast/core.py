import numpy as np
import pandas as pd
import calendar

# Data Processing

# load dataset
E1415 = pd.read_csv('data/E1415.csv')
E1516 = pd.read_csv('data/E1516.csv')
E1617 = pd.read_csv('data/E1617.csv')
E1718 = pd.read_csv('data/E1718test.csv')

# concat dataset
frames = [E1415,E1516,E1617,E1718]
data = pd.concat(frames)[['Date','HomeTeam','AwayTeam','FTR','FTHG','FTAG','Referee','B365H','B365D','B365A']]

# remove nan
data.dropna(how='any',axis=0,inplace=True)

# get month cat
data['month'] = pd.DatetimeIndex(data['Date']).month.astype(int)
data['month']= data['month'].apply(lambda x: calendar.month_abbr[x])

def data_processing(data):
    df_with_dummies = pd.get_dummies(data, columns = ['HomeTeam','AwayTeam','FTR','Referee','month'])
    df_with_dummies.drop(['Date','FTHG','FTAG'], axis=1, inplace=True)
    return(df_with_dummies)


processed_data=data_processing(data)

# Modelisation

data_model = processed_data.head(processed_data.shape[0]-E1718.shape[0])

from sklearn.model_selection import train_test_split
train_set, validation_set = train_test_split(data_model, test_size = 0.3)

y_train = train_set[['FTR_A','FTR_D','FTR_H']]
x_train  = train_set.drop(['FTR_A','FTR_D','FTR_H'],axis=1)
y_validation = validation_set[['FTR_A','FTR_D','FTR_H']]
x_validation  = validation_set.drop(['FTR_A','FTR_D','FTR_H'],axis=1)

from keras.models import Sequential
from keras.layers import Dense,Dropout

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

scores = model.evaluate(x_validation.values,y_validation.values)
print("\n%s: %.2f%%" % (model.metrics_names[1], scores[1]*100))

# Final test on 2017 data
data_end = processed_data.tail(80)

y_test = data_end[['FTR_A','FTR_D','FTR_H']]
x_test  = data_end.drop(['FTR_A','FTR_D','FTR_H'],axis=1)

predictions = pd.DataFrame(model.predict(x_test.values))

scores = model.evaluate(x_test.values,y_test.values)
print("\n%s: %.2f%%" % (model.metrics_names[1], scores[1]*100))

predictions.columns=['FTR_A','FTR_D','FTR_H']
predictions.round(2).head(10)