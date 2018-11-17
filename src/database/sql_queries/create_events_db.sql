-- Table: metadata

DROP TABLE public.events;

CREATE TABLE public.events
(
    game_id varchar(80),
    event_id varchar(80),
    minute int,
    second int,
    team_id varchar(80),
    player_id varchar(80),
    x int,
    y int,
    type_value int,
    type_name varchar(80),
    outcome_type_value int,
    outcome_type_name varchar(80),
    is_touch int
);