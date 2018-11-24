-- Table: event_shots

DROP TABLE public.event_shots;

CREATE TABLE public.event_shots
(
    game_id varchar(80),
    event_id varchar(80),
    x_shot float,
    y_shot float,
    goal_distance float,
    type_value float,
    type_name varchar(80),
    player_id varchar(80),
    team_id varchar(80),
    is_goal float,
    big_chance float
);