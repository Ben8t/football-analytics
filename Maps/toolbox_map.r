# toolbox_map.r
# Function definition for football map such as passnetwork, shot locations, etc...

library(tidyverse)
library(hrbrthemes)
library(ggforce)
library(jsonlite)
library(grid)
library(gridExtra)
library(igraph)
library(ggnetwork)

#data = jsonlite::fromJSON(jsonfile)

# EVENT PROCESSING #
event_to_dataframe <- function(data){
    # Transform json data to dataframe
    event = data.frame(id=data$events$id,
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

playersId_playersNames <- function(data){
    # Gather player names with player id
    playersId_playersNames = data$playerIdNameDictionary %>% 
        t %>% 
        as.data.frame() %>% 
        t %>% 
        as.data.frame() %>% 
        tibble::rownames_to_column() %>% 
        select(playerName=V1,playerId=rowname) %>% 
        mutate(playerId=as.numeric(playerId),playerName=unlist(playerName))
    return(playersId_playersNames)
}

teamsId_teamsNames <- function(data){
    # Gather team id with tema names
    teamsId_teamsNames = data.frame(teamId=c(data$home$teamId, data$away$teamId),
                                    teamName=c(data$home$name, data$away$name))
    return(teamsId_teamsNames)
}

event_cleaning <- function(data){
    # return all event with eventId, minute, second, teamName, playerName, x, y, typeDisplayName, perido, isTouch, outcome
    # clearing event data 
    event_cleared = event_to_dataframe(data) %>%
            select(eventId, minute, second, teamId, playerId, x, y, typeDisplayName, typeValue, period, isTouch, outcome) %>%
            mutate(x=105*x/100, y=68*y/100) %>% # normalize x and y to fit with FIFA dimensions
            na.omit()

    # get player and teams name with corresponding id
    playersId_playersNames = playersId_playersNames(data)
    teamsId_teamsNames = teamsId_teamsNames(data)

    # join all
    simple_event = left_join(event_cleared, playersId_playersNames, by=c("playerId")) %>%
            left_join(., teamsId_teamsNames, by=c("teamId")) %>%
            select(-teamId, -playerId)

    return(simple_event)
}

lineup_from_event <- function(data){
    lineup = list()
    lineup$home_lineup_id = data$home$formations$playerIds[[1]] %>% as.data.frame() %>% select(.,playerId=.) %>% slice(1:11) %>% as.data.frame()
    lineup$away_lineup_id = data$home$formations$playerIds[[1]] %>% as.data.frame() %>% select(.,playerId=.) %>% slice(1:11) %>% as.data.frame()
    lineup$home_lineup_maps = data$home$formations$formationPositions[[1]]
    return(lineup)
}

mround <- function(x,base){ 
        base*round(x/base) 
} 

angle_between_points <- function(p1_x, p1_y, p2_x, p2_y){
    angle <- (atan2((p2_y - p1_y),(p2_x - p1_x)) * 180 / pi)
    angle = mround(angle, 15)
    return(angle)
}

get_players_passes <- function(lineup_event){
    player_passes=data.frame()
    for(i in c(1:(nrow(lineup_event)-2))){
        if(lineup_event$typeValue[i]==1 & lineup_event$typeValue[i+1]==1){
            player_passes = rbind(player_passes,data.frame(from=lineup_event$playerName[i], 
                from_x=lineup_event$x[i], 
                from_y=lineup_event$y[i], 
                to=lineup_event$playerName[i+1],
                to_x=lineup_event$x[i+1],
                to_y=lineup_event$y[i+1],
                team=lineup_event$teamName[i]))
        }
    }
    player_passes = player_passes %>% 
        mutate(angle=-angle_between_points(from_x, from_y, to_x, to_y), distance=sqrt((to_y - from_y)^2 + (to_x - from_x)^2))
    return(player_passes)
}


load_many_games <- function(files){
    # file_list = list.files("data/arsenal1718/", full.names=TRUE)
    # dataframe_events = load_many_games(file_list)
    dataframe_events <- list()
    i=1
    for(file in files){
        print(file)
        data = jsonlite::fromJSON(file)
        dataframe_events[[i]] <- data
        i = i + 1
    }
    return(dataframe_events)
}

# MAPS PROCESSING #
get_all_from_game_player <- function(data, player){
    event = event_cleaning(data) %>%
            filter(playerName==player) %>%
            select(playerName, x, y, typeDisplayName, minute, period)
    return(event)
}

get_all_from_game_team <- function(data, team){
    event = event_cleaning(data) %>%
            filter(teamName==team) %>%
            select(teamName, playerName, x, y, typeDisplayName, minute, period)
    return(event)
}

gather_all_from_many_games_player <- function(dataframe_events, player){
    # dataframe_events is a list of each games event dataframe
    final_data = data.frame()
    for(data in dataframe_events){
        game_player = get_all_from_game_player(data, player)
        final_data = rbind(final_data, game_player)
    }
    return(final_data)
}

