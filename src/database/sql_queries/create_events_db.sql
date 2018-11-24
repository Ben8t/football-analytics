-- Table: metadata

DROP TABLE public.events;

CREATE TABLE public.events
(
    game_id varchar(80),
    event_id varchar(80),
    minute float,
    second float,
    team_id varchar(80),
    player_id varchar(80),
    x float,
    y float,
    type_value float,
    type_name varchar(80),
    outcome_type_value float,
    outcome_type_name varchar(80),
    is_touch float
);