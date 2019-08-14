SELECT DISTINCT type_name FROM events

WITH score_timeline AS (
	SELECT
		events.game_id,
		events.minute,
		events.second,
		events.team_id,
		metadata.home_team_id,
		metadata.away_team_id,
		RANK() OVER(PARTITION BY events.game_id ORDER BY events.minute) AS ranking
	FROM events
	LEFT JOIN metadata
	ON events.game_id = metadata.game_id
	WHERE type_name = 'Goal'
)