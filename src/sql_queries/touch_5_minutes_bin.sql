SELECT
    *,
    10 * (TRUNC(time/600) + 1) AS bin
FROM (
    SELECT
        minute * 60 + second AS time,
		minute,
		second,
        x,
        y,
        team_id
    FROM events
    WHERE game_id = 'bc5f0c1e29733ac5bc94c6e84cdb641f' AND is_touch = 1
) AS base
ORDER BY time