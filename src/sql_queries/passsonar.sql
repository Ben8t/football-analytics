WITH full_pass AS (
	SELECT * FROM event_pass
	WHERE game_id IN (SELECT game_id FROM metadata WHERE "startDate" > '2017-06-01' AND "startDate" < '2018-06-01')
	AND player_id = '83078'
)

SELECT 
	angle,
	COUNT(angle) AS freq,
	AVG(distance) AS distance
FROM (
	SELECT
		x_begin,
		y_begin,
		x_end,
		y_end,
		SQRT(POWER((y_end - y_begin),2) + POWER((x_end - x_begin),2)) AS distance,
		-15 * ROUND((ATAN2((y_end - y_begin), (x_end - x_begin)) * 180 / PI())/15) AS angle
	FROM full_pass
) AS compute
WHERE angle IS NOT NULL
GROUP BY angle
ORDER BY angle