WITH shots AS (
	SELECT 
		game_id, 
		event_id,
		x_shot,
		y_shot,
		goal_distance,
		big_chance,
        is_goal
	FROM event_shots
)

SELECT
    game_id,
    event_id,
    team_id,
    player_id,
	minute,
	second,
	x_shot,
	y_shot,
	goal_distance,
	big_chance,
    previous_type_name,
    previous_x,
    previous_y,
    is_goal
FROM (
    SELECT
        events.*,
        x_shot,
        y_shot,
        goal_distance,
        big_chance,
        is_goal,
        LEAD(x) OVER(ORDER BY events.game_id, minute, second) AS previous_x,
        LEAD(y) OVER(ORDER BY events.game_id, minute, second) AS previous_y,
        LEAD(type_name) OVER(ORDER BY events.game_id, minute, second) AS previous_type_name
    FROM events
    LEFT JOIN shots
    ON events.game_id = shots.game_id AND events.event_id = shots.event_id
    ORDER BY events.game_id, minute, second
) AS event_shots
WHERE x_shot IS NOT NULL
