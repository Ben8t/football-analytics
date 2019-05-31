WITH teams AS (
	SELECT DISTINCT
		home_team_id AS team_id,
		home_team_name AS team_name
	FROM metadata
)

SELECT DISTINCT
	event_shots.game_id,
	event_shots.event_id,
	events.minute,
	teams.team_name,
	metadata.home_team_name,
	metadata.away_team_name,
	CASE
		WHEN teams.team_name=metadata.home_team_name THEN home_team_name
		ELSE away_team_name
	END AS goal_for,
	CASE
		WHEN teams.team_name=metadata.away_team_name THEN home_team_name
		ELSE away_team_name
	END AS goal_against
FROM event_shots
LEFT JOIN events
ON events.event_id = event_shots.event_id
LEFT JOIN teams
ON teams.team_id = event_shots.team_id
LEFT JOIN metadata
ON metadata.game_id = event_shots.game_id
WHERE is_goal=1 AND
metadata."startDate" > '2018-07-01'