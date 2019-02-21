# core.r
library(dplyr)
library(rvest)
library(hrbrthemes)
library(jsonlite)

event_to_dataframe <- function(data) {
    # Transform json data to dataframe
    #
    # Args:
    #   data: data loaded from json
    #
    # Returns:
    #   dataframe with event data
    event <- data.frame(id=data$events$id,
                       eventId=data$events$eventId,
                       minute=data$events$minute,
                       second=data$events$second,
                       teamId=data$events$teamId,
                       playerId=data$events$playerId,
                       x=data$events$x,
                       y=data$events$y,
                       typeValue=data$events$type$value,
                       typeDisplayName=data$events$type$displayName,
                       period=data$events$period$value,
                       isTouch=data$events$isTouch,
                       outcome=data$events$outcomeType$value)
    return(event)
}

get_playersId_playersNames <- function(data) {
    # Gather player names with player id
    #
    # Args:
    #   data: data loaded from json
    #
    # Returns:
    #   dataframe with players id and players names
    playersId_playersNames <- data$playerIdNameDictionary %>% 
        t %>% 
        as.data.frame() %>% 
        t %>% 
        as.data.frame() %>% 
        tibble::rownames_to_column() %>% 
        select(playerName=V1, playerId=rowname) %>% 
        mutate(playerId=as.numeric(playerId), playerName=unlist(playerName))
    return(playersId_playersNames)
}

get_teamsId_teamsNames <- function(data) {
    # Gather team id with team names
    #
    # Args:
    #   data: data loaded from json
    #
    # Returns:
    #   dataframe with teams id and teams names
    teamsId_teamsNames <- data.frame(teamId=c(data$home$teamId, data$away$teamId),
                                    teamName=c(data$home$name, data$away$name))
    return(teamsId_teamsNames)
}

event_cleaning <- function(data) {
    # Cleaning raw event data
    #
    # Args:
    #   data: data loaded from json
    #
    # Returns
    #   event data cleaned and filtered
    event_cleaned <- event_to_dataframe(data) %>%
            select(eventId, minute, second, teamId, playerId, x, y, typeDisplayName, typeValue, period, isTouch, outcome) %>%
            mutate(x=105*x/100, y=68*y/100) %>% # normalize x and y to fit with FIFA dimensions
            na.omit()
    # get player and teams name with corresponding id
    playersId_playersNames <- get_playersId_playersNames(data)
    teamsId_teamsNames <- get_teamsId_teamsNames(data)
    # join all
    simple_event <- left_join(event_cleaned, playersId_playersNames, by=c("playerId")) %>%
            left_join(., teamsId_teamsNames, by=c("teamId"))
    return(simple_event)
}

get_game_information_text <- function(data, team) {
    # Get game information such as scoreboard and teams
    #
    # Args:
    #   data: data loaded from json
    #   team: either "home" or "away"
    #
    # Returns:
    #   game scoreboard (example: "Arsenal against Liverpool - 2:1")
    home_team <- data$home$name
    away_team <- data$away$name
    score_home <- unlist(strsplit(data$score, "\\s+"))[1]
    score_away <- unlist(strsplit(data$score, "\\s+"))[3]
    if (team=="home") {
        final_text <- paste0(home_team," against ",away_team," - ",score_home,":",score_away)
    } else if (team=="away") {
        final_text <- paste0(away_team," away at ", home_team," - ", score_home, ":", score_away)
    }
    return(final_text)
}

get_game_datetime <- function(data) {
    # Parse datatime from game data
    #
    # Args:
    #   data: data loaded from json
    #
    # Returns:
    #   clean datetime
    datetime <- data$timeStamp %>% substr(., 1,10)
    day <- substr(datetime, 9, 10)
    month <- substr(datetime, 6, 7)
    year <- substr(datetime, 1, 4)
    clean_datetime <- paste0(day, "/", month, "/", year)
    return(clean_datetime)
}

get_lineup <- function(data, team) {
    # Get team lineup (starting eleven)
    #
    # Args:
    #   data: data loaded from json
    #   team: either "home" or "away"
    #
    # Return:
    #   lineup
    if (team == "home") {
        lineup <- cbind(data$home$formations$playerIds[[1]] %>% as.data.frame() %>% select(., playerId=.) %>% slice(1:11),
            data$home$formations$formationPositions[[1]])
    } else if (team == "away") {
        lineup <- cbind(data$away$formations$playerIds[[1]] %>% as.data.frame() %>% select(., playerId=.) %>% slice(1:11),
            data$away$formations$formationPositions[[1]])
    }
    return(lineup)
}

mround <- function(x,base) {
    # Round number according to a base
    base * round(x/base) 
} 

angle_between_points <- function(p1_x, p1_y, p2_x, p2_y, rounding){
    # Compute angle between to points (ie. vectors)
    angle <- (atan2((p2_y - p1_y), (p2_x - p1_x)) * 180 / pi)
    angle <- mround(angle, rounding)
    return(angle)
}

get_players_passes <- function(team_event) {
    # Build dataframe with player passes
    #
    # Args:
    #   team_event: dataframe containing event data for a specific team
    #
    # Returns:
    #   passes destination for each player
    player_passes <- data.frame()
    for (i in c(1:(nrow(team_event)-2))) {
        if (team_event$typeValue[i]==1 & team_event$typeValue[i+1]==1) {
            player_passes = rbind(player_passes, data.frame(from=team_event$playerName[i], 
                from_x=team_event$x[i], 
                from_y=team_event$y[i], 
                to=team_event$playerName[i+1],
                to_x=team_event$x[i+1],
                to_y=team_event$y[i+1],
                team=team_event$teamName[i]))
        }
    }
    player_passes <- player_passes %>% 
        mutate(angle=-angle_between_points(from_x, from_y, to_x, to_y, 15), distance=sqrt((to_y - from_y)^2 + (to_x - from_x)^2))
    return(player_passes)
}

get_team_name <- function(data, team) {
    # Get team name
    #
    # Args:
    #   data: data loaded from json
    #   team: either "home" or "away"
    #
    # Return:
    #   team name
    if (team == "home") {
        team_name <- data$home$name
    } else if (team == "away") {
        team_name <- data$away$name
    }
    return(team_name)
}
