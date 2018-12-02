SELECT
	game_id,
	event_id,
	type_name,
    event_goal,
	x_begin,
	y_begin,
	x_end,
	y_end,
	CASE
		WHEN type_value = 16 THEN 1
		ELSE 0 
	END
	AS is_goal
FROM (
	SELECT
		player_id,
		game_id,
		event_id,
		type_name,
        outcome_type_value,
		x AS x_begin,
		y AS y_begin,
		LEAD(x) OVER(PARTITION BY game_id ORDER BY minute, second) AS x_end,
		LEAD(y) OVER(PARTITION BY game_id ORDER BY minute, second) AS y_end,
		LEAD(type_value, 2) OVER(PARTITION BY game_id ORDER BY minute, second) AS type_value,
        LEAD(event_id, 2) OVER(PARTITION BY game_id ORDER BY minute, second) AS event_goal
	FROM events
    ORDER BY game_id
) AS process_pass
WHERE 
	type_name = 'Pass' AND 
	outcome_type_value = 1 AND 
	player_id = '13756' AND
	game_id IN (SELECT game_id FROM metadata WHERE "startDate" >'2017-07-01')
