# data_processing.py

import numpy as np
import pandas as pd
import calendar

def data_processing(data):
	"""Processing data.
	Process data in view to modelisation process which need clean inputs - for example numerical data.
	Arg:
		data : A pandas DataFrame (almost raw data)
	Return:
		A pandas DataFrame with only numerical data
	"""
	data.dropna(how='any',axis=0,inplace=True)

	# Get month categories
	data['month'] = pd.DatetimeIndex(data['Date']).month.astype(int)
	data['month'] = data['month'].apply(lambda x: calendar.month_abbr[x])

	# Set dummies variables for qualitative data
	df_with_dummies = pd.get_dummies(data, columns = ['HomeTeam','AwayTeam','FTR','Referee','month'])
	df_with_dummies.drop(['Date','FTHG','FTAG'], axis=1, inplace=True)

	return df_with_dummies


def split_dataset(data,split_rate,output_variable):
	"""Split dataset in 4 parts : x_train, y_train, x_test, y_test.
	Args: 
		split_rate : often 0.3
		output_variable : variable to predict

	Returns: 
		x_train, y_train : train dataset to fit model.
		x_test : use for predictions
		y_test : use for error calculation
	"""
	train_set, test_set = train_test_split(data, test_size = split_rate)
	x_train  = train_set.drop(output_variable,axis=1)
	y_train = train_set[output_variable]
	x_test  = test_set.drop(output_variable,axis=1)
	y_test = test_set[output_variable]
	return x_train,y_train,x_test,y_test