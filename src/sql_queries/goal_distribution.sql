WITH teams AS (
	SELECT DISTINCT
		home_team_id AS team_id,
		home_team_name AS team_name
	FROM metadata
)

SELECT DISTINCT
	event_shots.event_id,
	minute,
	teams.team_name
FROM event_shots
LEFT JOIN events
ON events.event_id = event_shots.event_id
LEFT JOIN teams
ON teams.team_id = event_shots.team_id
WHERE is_goal=1