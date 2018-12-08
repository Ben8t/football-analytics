SELECT
	"startDate",
	player_name,
	CASE WHEN
		player_position LIKE '%Sub' THEN 'sub'
	ELSE 'tit' END AS pos
FROM player_base
INNER JOIN (SELECT game_id, "startDate" FROM metadata WHERE "startDate" > '2017-07-01' AND "startDate" < '2018-07-01') AS met
ON met.game_id = player_base.game_id
WHERE team_id = '32'
GROUP BY "startDate", player_name, player_position
ORDER BY "startDate"