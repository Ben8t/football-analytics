-- Table: metadata

DROP TABLE public.metadata;

CREATE TABLE public.metadata
(
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