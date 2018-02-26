# shotMap.r

library(tidyverse)
library(hrbrthemes)
library(jsonlite)
library(grid)
library(gridExtra)
library(igraph)
library(ggnetwork)

get_lineup_and_final_text <- function(data,TEAM){
    # Return TEAM lineup and create final text for design purposes (title)
    home_team = data$home$name
    away_team = data$away$name
    score_home = unlist(strsplit(data$score, "\\s+"))[1]
    score_away = unlist(strsplit(data$score, "\\s+"))[3]
    if(TEAM=="home"){
        lineup = data$home$formations$playerIds[[1]] %>% as.data.frame() %>% select(.,playerId=.) %>% slice(1:11)
        final_text = paste0(home_team," against ",away_team," - ",score_home,":",score_away)
    }else if(TEAM=="away"){
        lineup = data$away$formations$playerIds[[1]] %>% as.data.frame() %>% select(.,playerId=.) %>% slice(1:11)
        final_text = paste0(away_team," away at ",home_team," - ",score_home,":",score_away)
    }
    return(c(lineup,final_text))
}

get_players_passes <- function(lineup_event){
    player_passes=data.frame()
    for(i in c(1:(nrow(lineup_event)-2))){
        if(lineup_event$typeValue[i]==1 & lineup_event$typeValue[i+1]==1){
            player_passes = rbind(player_passes,data.frame(from=lineup_event$playerName[i],to=lineup_event$playerName[i+1]))
        }
    }
    return(player_passes)
}
 
get_players_shots <- function(lineup_event){
    # return a dataframe with all shots (on/off target, goals) with players and position (x,y)
    players_shots = lineup_event %>% 
                    na.omit() %>% 
                    filter(typeValue==15 | typeValue==16 | typeValue==13)
    return(players_shots)
}

# In command line with : Rscript passNetwork.r "data/data.json" "home" "#90caf9" 5
# args = commandArgs(trailingOnly=TRUE)

# Or in R shell
args = c("data/divers/England-Premier-League-2017-2018-Manchester-United-Chelsea.json","home","#90caf9",5)

# VARIABLE
DATA_FILE = args[1]
TEAM = args[2]
TEAM_COLOR =args[3]
PASS_NUMBERS = args[4]

# Load data from json file
data = jsonlite::fromJSON(DATA_FILE)

# get all event data
event = data.frame(id=data$events$id,eventId=data$events$eventId,minute=data$events$minute,second=data$events$second,teamId=data$events$teamId,playerId=data$events$playerId,x=data$events$x,y=data$events$y,typeValue=data$events$type$value,typeDisplayName=data$events$type$displayName,period=data$events$period$value,isTouch=data$events$isTouch,outcome=data$events$outcomeType$value)

# get player list
all_players= data$playerIdNameDictionary %>%
    t %>% 
    as.data.frame() %>% 
    t %>% 
    as.data.frame() %>% 
    tibble::rownames_to_column() %>% 
    select(playerName=V1,playerId=rowname) %>% 
    mutate(playerId=as.numeric(playerId),playerName=unlist(playerName))

event = left_join(event,all_players,by=c("playerId"))  # add player names to event dataframe
lineup_final_text = get_lineup_and_final_text(data,TEAM)
lineup = lineup_final_text[1]  # get lineup for either home or away team
lineup_event = event %>% filter(playerId %in% lineup$playerId)  # filter event accorting to home or away team

player_shots = get_players_shots(lineup_event)  # get passes for each teammates
player_shots = player_shots %>% select(playerName,x,y,typeDisplayName)

# Vertical (x=x, y=y)
map <-  ggplot(data=player_shots,aes(x=x,y=y))+
    geom_segment(aes(x = 100, y = 0, xend = 100, yend = 100), colour="#eee9d6") + geom_segment(aes(x = 50, y = 0, xend = 100, yend = 0), colour="#eee9d6") + geom_segment(aes(x = 50, y = 100, xend = 100, yend = 100), colour="#eee9d6") + geom_segment(aes(x=50, y= 0, xend = 50, yend = 100), colour="#eee9d6") + geom_segment(aes(x=50, y= 0, xend = 50, yend = 100), colour="#eee9d6") + geom_segment(aes(x=83, y=21.2, xend=100, yend=21.2), colour="#eee9d6") + geom_segment(aes(x=83, y=21, xend=83, yend=79), colour="#eee9d6") + geom_segment(aes(x=83, y=79, xend=100, yend=79), colour="#eee9d6")+ geom_segment(aes(x=100, y=36.8, xend=94.2, yend=36.8), colour="#eee9d6") + geom_segment(aes(x=94.2, y=36.8, xend=94.2, yend=63.2), colour="#eee9d6") + geom_segment(aes(x=100, y= 63.2, xend=94.2, yend=63.2), colour="#eee9d6") +
    stat_density2d(aes(fill=..level..,alpha=..level..),geom='polygon',colour="#eee9d6", show.legend=FALSE) +
    scale_fill_gradient2(low = "#a7ffeb", mid="#64ffda", high = "#1de9b6") +
    geom_point(aes(color = typeDisplayName), size=2) +
    scale_colour_manual(values = c("#ffc400", "#448aff", "#b388ff"), name = "Shot type") +
    theme_ipsum_rc()+
    theme(axis.title=element_blank(),axis.text=element_blank(),axis.ticks=element_blank(),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),panel.background = element_blank()) +
    theme(legend.text = element_text(colour="#eee9d6", size=15), legend.title = element_text(colour="#eee9d6", size=20)) +
    theme(panel.background = element_rect(fill = '#293555', colour = '#293555'), plot.background = element_rect(fill = "#293555"))

# Horizontal (x=y, y=-x)
map <-  ggplot(data=player_shots,aes(x=y,y=-x))+
    geom_segment(aes(x = 0, y = -100, xend = 100, yend = -100), colour="#eee9d6") + geom_segment(aes(x=0, y= -50, xend = 100, yend = -50), colour="#293555") + geom_segment(aes(x=21.2, y=-83, xend=21.2, yend=-100), colour="#eee9d6") + geom_segment(aes(x=21, y=-83, xend=79, yend=-83), colour="#eee9d6") + geom_segment(aes(x=79, y=-83, xend=79, yend=-100), colour="#eee9d6")+ geom_segment(aes(x=36.8, y=-100, xend=36.8, yend=-94.2), colour="#eee9d6") + geom_segment(aes(x=36.8, y=-94.2, xend=63.2, yend=-94.2), colour="#eee9d6") + geom_segment(aes(x=63.2, y= -100, xend=63.2, yend=-94.2), colour="#eee9d6") +
    stat_density2d(aes(fill=..level..,alpha=..level..),geom='polygon',colour="#eee9d6", show.legend=FALSE) +
    scale_fill_gradient2(low = "#a7ffeb", mid="#64ffda", high = "#1de9b6") +
    geom_point(aes(color = typeDisplayName), size=2) +
    scale_colour_manual(values = c("#ffc400", "#448aff", "#b388ff"), name = "Shot type") +
    theme_ipsum_rc()+
    theme(axis.title=element_blank(),axis.text=element_blank(),axis.ticks=element_blank(),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),panel.background = element_blank()) +
    theme(legend.text = element_text(colour="#eee9d6", size=15), legend.title = element_text(colour="#eee9d6", size=20)) +
    theme(panel.background = element_rect(fill = '#293555', colour = '#293555'), plot.background = element_rect(fill = "#293555"))

ggsave(filename = paste0("img/g_shotmap_tmp.png"),map,width=10,height=7.5,dpi=300)



