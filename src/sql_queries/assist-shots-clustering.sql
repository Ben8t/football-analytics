WITH assists AS (
        SELECT
            game_id,
            event_id,
            x_begin AS x_pass_begin,
            y_begin AS y_pass_begin,
            x_end AS x_pass_end,
            y_end AS y_pass_end
        FROM event_pass 
		WHERE is_assist=1
),
	
shots AS (
	SELECT
		game_id,
		event_id,
		x_shot,
		y_shot
	FROM event_shots
),

events AS (
SELECT
	game_id,
	event_id,
	LEAD(event_id,1) OVER (ORDER BY game_id, minute, second) AS next_event_id,
	minute,
	second,
    player_id,
    team_id
FROM events
ORDER BY game_id, minute, second
)

SELECT * FROM (
    SELECT
        events.game_id,
        events.event_id,
        events.next_event_id,
        events.minute,
        events.second,
        events.player_id,
        events.team_id,
        assists.x_pass_begin,
        assists.y_pass_begin,
        assists.x_pass_end,
        assists.y_pass_end,
        shots.x_shot,
        shots.y_shot
    FROM events
    INNER JOIN assists
    ON events.event_id = assists.event_id
    LEFT JOIN shots
    ON events.next_event_id = shots.event_id
) AS fully
WHERE game_id IN (
    SELECT game_id FROM metadata WHERE (home_team_id = '13' OR away_team_id = '13') AND "startDate" > '2017-07-01' AND "startDate" < '2018-07-01'
)
AND team_id != '13'