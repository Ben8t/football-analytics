SELECT x_shot, y_shot, goal_distance, big_chance, event_shots.game_id, "startDate" FROM event_shots
LEFT JOIN metadata
ON metadata.game_id = event_shots.game_id
WHERE event_shots.game_id IN (
	SELECT game_id FROM metadata
	WHERE (home_team_id = '{team_id}' OR away_team_id = '{team_id}')
	AND CAST("startDate" AS DATE) < CAST('{date}' AS DATE)
	ORDER BY CAST("startDate" AS DATE) DESC
	LIMIT {past_offset}
)
AND team_id='{team_id}'
ORDER BY "startDate"