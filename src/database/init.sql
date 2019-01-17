-- Table: event_shots
DROP TABLE IF EXISTS public.event_pass;
CREATE TABLE public.event_pass(
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
-- Table: event_shots
DROP TABLE IF EXISTS public.event_shots;
CREATE TABLE public.event_shots(
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
-- Table: metadata
DROP TABLE IF EXISTS public.events;
CREATE TABLE public.events(
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
-- Table: metadata
DROP TABLE IF EXISTS public.metadata;
CREATE TABLE public.metadata(
    "game_id" varchar(80),
    "weatherCode" varchar(80),
    "timeStamp" varchar(80),
    "score" varchar(80),
    "minuteExpanded" int,
    "periodCode" int,
    "startDate" varchar(80),
    "htScore" varchar(80),
    "elapsed" varchar(80),
    "venueName" varchar(80),
    "maxMinute" int,
    "expandedMaxMinute" int,
    "timeoutInSeconds" varchar(80),
    "attendance" int,
    "statusCode" int,
    "etScore" varchar(80),
    "startTime" varchar(80),
    "maxPeriod" int,
    "ftScore" varchar(80),
    "pkScore" varchar(80),
    "home_team_id" varchar(80), 
    "home_team_name" varchar(80), 
    "home_manager_name" varchar(80), 
    "home_formation" varchar(80), 
    "away_team_id" varchar(80), 
    "away_team_name" varchar(80), 
    "away_manager_name" varchar(80),
    "away_formation" varchar(80),
    "home_score" int,
    "away_score" int,
    "result" varchar(80)
);
-- Table: metadata
DROP TABLE IF EXISTS public.player_base;
CREATE TABLE public.player_base(
    game_id  varchar(80),
    field varchar(80),
    team_id varchar(80),
    player_id varchar(80),
    player_name varchar(80),
    player_position varchar(80),
    player_height float,
    player_weight float,
    player_age int
);