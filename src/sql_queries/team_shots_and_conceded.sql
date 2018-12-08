-- gather team shots and conceded ones (all games)
SELECT * FROM event_shots
LEFT JOIN (
    SELECT game_id, "startDate" FROM metadata
) AS met
ON met.game_id = event_shots.game_id
WHERE event_shots.game_id IN (
    SELECT game_id FROM metadata WHERE home_team_id = '18' OR away_team_id = '18'
)
