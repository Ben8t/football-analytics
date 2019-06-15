SELECT
	game_id,
	"startDate",
	home_team_id,
	away_team_id,
	CASE
		WHEN result='home' THEN 0
		WHEN result='draw' THEN 1
		WHEN result='away' THEN 2
	ELSE NULL 
	END AS result
FROM metadata