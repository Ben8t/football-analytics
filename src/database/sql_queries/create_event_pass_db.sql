-- Table: event_shots

DROP TABLE public.event_pass;

CREATE TABLE public.event_pass
(
    game_id varchar(80),
    event_id varchar(80),
    x_begin float,
    y_begin float,
    x_end float,
    y_end float,
    goal_distance float,
    type_value float,
    type_name varchar(80),
    player_id varchar(80),
    team_id varchar(80),
    is_assist float,
    key_pass float,
    big_chance_created float
);


