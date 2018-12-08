SELECT * FROM event_pass
WHERE game_id IN (SELECT game_id FROM metadata WHERE "startDate" > '2017-06-01' AND "startDate" < '2018-06-01')
AND player_id = '97752'
