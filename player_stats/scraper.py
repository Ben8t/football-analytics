import glob
import json
import pandas as pd

list_files = glob.glob("./data/*.json")

json_data = [json.load(open(f)) for f in list_files]

# print(json_data[0]['entity']['name']['display'])

# data = [[elm['entity']['name']['first'],elm['entity']['name']['last']] for elm in json_data]

# print(data)

# df = pd.DataFrame(data)
# df.columns = ["first","name"]

# print(df)

data =[]
for player in json_data:
	player_id = player['entity']['playerId']
	name = player['entity']['name']['display']
	country = player['entity']['nationalTeam']['country']
	position1 = player['entity']['info']['position']
	position2 = player['entity']['info']['positionInfo']
	age = player['entity']['age'][0:2]
	mins_played=0
	appearances=0
	goal=0
	goals_assist=0
	open_play_pass=0
	fwd_pass=0
	backward_pass=0
	accurate_pass=0
	total_cross=0
	accurate_cross=0
	total_tackle=0
	won_tackle=0
	shot_on_target=0
	shot_off_target=0
	interception=0
	for stat in player['stats']:
		if(stat['name']=="mins_played"): mins_played = stat['value']
		if(stat['name']=="appearances"): appearances = stat['value']
		if(stat['name']=="goals"): goal = stat['value']
		goals_assist=stat['value'] if stat['name']=="goals_assist" else 0
		if(stat['name']=="open_play_pass"): open_play_pass= stat['value']
		if(stat['name']=="fwd_pass"): fwd_pass= stat['value']
		if(stat['name']=="backward_pass"): backward_pass= stat['value']
		if(stat['name']=="accurate_pass"): accurate_pass= stat['value']
		if(stat['name']=="total_cross"): total_cross= stat['value']
		if(stat['name']=="accurate_cross"): accurate_cross= stat['value']
		if(stat['name']=="total_tackle"): total_tackle= stat['value']
		if(stat['name']=="won_tackle"): won_tackle= stat['value']
		if(stat['name']=="ontarget_scoring_att"): shot_on_target= stat['value']
		if(stat['name']=="shot_off_target"): shot_off_target= stat['value']
		if(stat['name']=="interception"): interception= stat['value']

	data.append([player_id,name,country,age,position1,position2,appearances,mins_played,goal*90/mins_played,goals_assist*90/mins_played,open_play_pass*90/mins_played,accurate_pass*90/mins_played,accurate_pass/open_play_pass,fwd_pass*90/mins_played,backward_pass*90/mins_played,accurate_cross/total_cross,won_tackle/total_tackle,shot_on_target,shot_off_target,interception])


df = pd.DataFrame(data)
df.columns = ["player_id","name","country","age","position1","position2","appearances","mins_played","goal_per90","assist_per90","pass_per90","accurate_pass_per90","pass_accuracy","fwd_pass_per90","backward_pass_per90","cross_accuracy","tackl accuracy",""]
print(df)


