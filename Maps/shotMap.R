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
args = commandArgs(trailingOnly=TRUE)

# Or in R shell
# args = c("data/divers/manUtd-newcastle18112017.json","home","#90caf9",5)

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


map <- ggplot(data=player_shots,aes(x=x,y=y,color=playerName)) + geom_density2d()
map <- ggplot(data=player_shots,aes(x=x,y=y)) +
    stat_density_2d(geom = "raster", aes(fill = ..density..), contour = FALSE) + 
    geom_point(aes(color = typeDisplayName)) + 
    geom_text(aes(label=playerName),hjust=0, vjust=0)
# plot and aesthetics
ggnetwork_data <- ggnetwork(igraph_data,layout=layout_bound,weights = "n")
map <- ggplot(ggnetwork_data, aes(x = x, y = y, xend = xend, yend = yend)) +
    geom_edges(aes(color = n),size=1,arrow = arrow(length = unit(9, "pt"), type = "closed"),curvature = 0.05) +
    scale_color_gradientn("Passes",colours = c("#b9f6ca","#69f0ae","#00e676","#1b5e20"))+
    geom_nodes(aes(size=nb_touch),shape = 21, colour = "white", fill = TEAM_COLOR, stroke = 1) +
    scale_size("Touches",range = c(0,15),limits=c(1,max(touch_coordinates_and_count$nb_touch)))+
    geom_nodelabel_repel(aes(label = vertex.names),color=TEAM_COLOR,box.padding = unit(1,"lines")) +
    theme_ipsum_rc()+
    theme(axis.title=element_blank(),axis.text=element_blank(),axis.ticks=element_blank(),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),panel.background = element_blank())

ggsave(filename = paste0("img/g_passnetwork_tmp.png"),map,width =14,height=8,dpi=300)
print(lineup_final_text[2])





