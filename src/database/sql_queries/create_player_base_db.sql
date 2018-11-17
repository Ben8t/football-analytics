-- Table: metadata

DROP TABLE public.player_base;

CREATE TABLE public.player_base
(
    game_id  varchar(80),
    field varchar(80),
    team_id varchar(80),
    player_id varchar(80),
    player_name varchar(80),
    player_position varchar(80),
    player_height int,
    player_weight int,
    player_age int
);