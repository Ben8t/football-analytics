SELECT SUM(is_goal) AS goal, "startDate" FROM event_shots
LEFT JOIN metadata
ON event_shots.game_id = metadata.game_id
WHERE event_shots.game_id IN (
	SELECT game_id FROM metadata
	WHERE (home_team_id = '{team_id}' OR away_team_id = '{team_id}')
	AND CAST("startDate" AS DATE) < CAST('{date}' AS DATE)
	ORDER BY CAST("startDate" AS DATE) DESC
	LIMIT {past_offset}
)
AND team_id!='{team_id}'
GROUP BY event_shots.game_id, "startDate", team_id
ORDER BY "startDate"