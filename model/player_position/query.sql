WITH players AS (
	SELECT * FROM (
        SELECT
            player_id, 
            player_name, 
            player_position, 
            player_height, 
            player_weight,
            COUNT(player_position) AS volume,
            MAX(COUNT(player_position)) OVER(PARTITION BY player_id) AS max_volume
        FROM player_base 
        WHERE player_position != 'Sub'
        GROUP BY player_id, player_name, player_position, player_height, player_weight
        ) AS player
        WHERE max_volume = volume
)

SELECT
	events.player_id,
    player_name,
    player_position,
    player_height,
    player_weight,
    CAST(SUM(CASE WHEN (type_name = 'Pass' AND outcome_type_value = 1) THEN 1 END) AS DECIMAL)/COUNT(DISTINCT game_id) AS successful_pass, 
	CAST(SUM(CASE WHEN (type_name = 'Pass' AND outcome_type_value = 0) THEN 1 END) AS DECIMAL)/COUNT(DISTINCT game_id) AS unsuccessful_pass,
    CAST(SUM(CASE WHEN (type_name = 'Goal') THEN 1 END) AS DECIMAL)/COUNT(DISTINCT game_id) AS goal,
    CAST(SUM(CASE WHEN (type_name IN ('SavedShot', 'Goal')) THEN 1 END) AS DECIMAL)/COUNT(DISTINCT game_id) AS successful_shot,
    CAST(SUM(CASE WHEN (type_name IN ('MissedShots', 'ShotOnPost')) THEN 1 END) AS DECIMAL)/COUNT(DISTINCT game_id) AS unsuccessful_shot, 
    CAST(SUM(CASE WHEN (type_name = 'Tackle' AND outcome_type_value = 1) THEN 1 END) AS DECIMAL)/COUNT(DISTINCT game_id) AS successful_tackle,
    CAST(SUM(CASE WHEN (type_name = 'Tackle' AND outcome_type_value = 0) THEN 1 END) AS DECIMAL)/COUNT(DISTINCT game_id) AS unsuccessful_tackle, 
    CAST(SUM(CASE WHEN (type_name = 'BallTouch') THEN 1 END) AS DECIMAL)/COUNT(DISTINCT game_id) AS ball_touch,
    CAST(SUM(CASE WHEN (type_name = 'Aerial' AND outcome_type_value = 1) THEN 1 END) AS DECIMAL)/COUNT(DISTINCT game_id) AS successful_aerial, 
    CAST(SUM(CASE WHEN (type_name = 'Aerial' AND outcome_type_value = 0) THEN 1 END) AS DECIMAL)/COUNT(DISTINCT game_id) AS unsuccessful_aerial,
    CAST(SUM(CASE WHEN (type_name = 'TakeOn' AND outcome_type_value = 1) THEN 1 END) AS DECIMAL)/COUNT(DISTINCT game_id) AS successful_takeon, 
    CAST(SUM(CASE WHEN (type_name = 'TakeOn' AND outcome_type_value = 0) THEN 1 END) AS DECIMAL)/COUNT(DISTINCT game_id) AS unsuccessful_takeon,
    CAST(SUM(CASE WHEN (type_name = 'Dispossessed') THEN 1 END) AS DECIMAL)/COUNT(DISTINCT game_id) AS dispossessed 
FROM events
LEFT JOIN players
ON events.player_id = players.player_id
GROUP BY events.player_id, player_name, player_position, player_height, player_weight


-- SELECT DISTINCT type_value, type_name FROM events ORDER BY type_value