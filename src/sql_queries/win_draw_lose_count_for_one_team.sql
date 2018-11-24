SELECT COUNT(result) AS nb_result, result FROM (
	SELECT CASE
		WHEN home_team_name = 'Arsenal' AND result='home' THEN 'win'
		WHEN (home_team_name = 'Arsenal' OR away_team_name = 'Arsenal') AND result='draw' THEN 'draw'
		WHEN away_team_name = 'Arsenal' AND result='away' THEN 'win'
		ELSE 'lose'
		END AS result
	FROM metadata
	WHERE (home_team_name = 'Arsenal' OR away_team_name = 'Arsenal')
) AS team_result
GROUP BY result