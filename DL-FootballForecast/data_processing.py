# data_processing.py

import numpy as np
import pandas as pd
import seaborn
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
import calendar


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


def heatmap(df):
	"""
	df is a dataframe
	show a map whith correlation
	"""
	correlation = df.corr()
	seaborn.set()
	sheatmap = seaborn.heatmap(correlation,annot=True)
	plt.show()

def data_processing1(data):
	"""Processing data.
	Process data in view to modelisation process which need clean inputs - for example numerical data.
	Arg:
		data : A pandas DataFrame (almost raw data)
	Return:
		A pandas DataFrame with only numerical data
	"""
	df = data[['Date','HomeTeam','AwayTeam','FTR','FTHG','FTAG','Referee','B365H','B365D','B365A']]
	df.dropna(how='any',axis=0,inplace=True)

	# Get month categories
	df['month'] = pd.DatetimeIndex(df['Date']).month.astype(int)
	df['month'] = df['month'].apply(lambda x: calendar.month_abbr[x])

	# Set dummies variables for qualitative data
	df_with_dummies = pd.get_dummies(df, columns = ['HomeTeam','AwayTeam','FTR','Referee','month'])
	df_with_dummies.drop(['Date','FTHG','FTAG'], axis=1, inplace=True)

	return df_with_dummies


def data_processing2(data):
	"""Processing data.
	Process data in view to modelisation process which need clean inputs - for example numerical data.
	Arg:
		data : A pandas DataFrame (almost raw data)
	Return:
		A pandas DataFrame with only numerical data
	"""
	df = data[['Date','HomeTeam','AwayTeam','FTR','FTHG','FTAG','Referee','B365H','B365D','B365A']]
	df.dropna(how='any',axis=0,inplace=True)

	# Get month categories
	df['month'] = pd.DatetimeIndex(df['Date']).month.astype(int)
	df['month'] = df['month'].apply(lambda x: calendar.month_abbr[x])

	# Set dummies variables for qualitative data
	df_with_dummies = pd.get_dummies(df, columns = ['HomeTeam','AwayTeam','FTR','Referee','month'])
	df_with_dummies.drop(['Date','FTHG','FTAG'], axis=1, inplace=True)

	return df_with_dummies