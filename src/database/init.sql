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

-- Table: metadata
DROP TABLE IF EXISTS public.team_style_cluster;
CREATE TABLE public.team_style_cluster(
    "team_id" varchar(80),
    cluster_0 float,
    cluster_1 float,
    cluster_2 float,
    cluster_3 float,
    cluster_4 float,
    cluster_5 float,
    cluster_6 float,
    cluster_7 float,
    cluster_8 float,
    cluster_9 float,
    cluster_10 float,
    cluster_11 float,
    cluster_12 float,
    cluster_13 float,
    cluster_14 float,
    cluster_15 float,
    cluster_16 float,
    cluster_17 float,
    cluster_18 float,
    cluster_19 float,
    cluster_20 float,
    cluster_21 float,
    cluster_22 float,
    cluster_23 float,
    cluster_24 float,
    cluster_25 float,
    cluster_26 float,
    cluster_27 float,
    cluster_28 float,
    cluster_29 float,
    cluster_30 float,
    cluster_31 float,
    cluster_32 float,
    cluster_33 float,
    cluster_34 float,
    cluster_35 float,
    cluster_36 float,
    cluster_37 float,
    cluster_38 float,
    cluster_39 float,
    cluster_40 float,
    cluster_41 float,
    cluster_42 float,
    cluster_43 float,
    cluster_44 float,
    cluster_45 float,
    cluster_46 float,
    cluster_47 float,
    cluster_48 float,
    cluster_49 float
);