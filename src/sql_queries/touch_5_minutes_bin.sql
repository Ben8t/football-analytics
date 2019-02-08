SELECT
    *,
    5 * (TRUNC(time/300) + 1) AS bin
FROM (
    SELECT
        minute * 60 + second AS time,
		minute,
		second,
        x,
        y,
        team_id
    FROM events
    WHERE game_id = '090a665e80376ff612a4201e81590f84' AND is_touch = 1
) AS base
ORDER BY time

ggplot(data=data %>% filter(team_id==175), aes(x=x, y=y)) + geom_point() + labs(title = 'Minute bin: {frame_time}') + transition_time(bin) +
+     ease_aes('linear')
> animate(a, 
+         duration = 20)