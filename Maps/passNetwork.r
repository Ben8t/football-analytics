# map_scrape.r
# WhoScored : copy(JSON.stringify(matchCentreData));
# Teams colors : https://docs.google.com/spreadsheets/d/1H4E8SfuZXglshXfNBNOxW6nWtsLfYfhXvRLB6bD_acA/edit?usp=sharing

 args = commandArgs(trailingOnly=TRUE)
# args = c("test.json","away","#90caf9",5)
library(tidyverse)
library(hrbrthemes)
library(jsonlite)
library(grid)
library(gridExtra)


# VARIABLE
DATA_FILE = args[1]
TEAM = args[2]
TEAM_COLOR =args[3]
PASS_NUMBERS = args[4]

# Data ---------------------------------------------------------------
# Load data from json file (WhoScored)
data = jsonlite::fromJSON(DATA_FILE)
# get event
event = data.frame(id=data$events$id,eventId=data$events$eventId,minute=data$events$minute,second=data$events$second,teamId=data$events$teamId,playerId=data$events$playerId,x=data$events$x,y=data$events$y,typeValue=data$events$type$value,typeDisplayName=data$events$type$displayName,period=data$events$period$value,isTouch=data$events$isTouch,outcome=data$events$outcomeType$value)
# get player list
player= data$playerIdNameDictionary %>%
    t %>% 
    as.data.frame() %>% 
    t %>% 
    as.data.frame() %>% 
    tibble::rownames_to_column() %>% 
    select(playerName=V1,playerId=rowname) %>% 
    mutate(playerId=as.numeric(playerId),playerName=unlist(playerName))

# Select team (home or away)
if(TEAM=="home"){
    lineup = data$home$formations$playerIds[[1]] %>% as.data.frame() %>% select(.,playerId=.) %>% slice(1:11)
}else if(TEAM=="away"){
    lineup = data$away$formations$playerIds[[1]] %>% as.data.frame() %>% select(.,playerId=.) %>% slice(1:11)
}

# Bind all data
full = left_join(event,player,by=c("playerId"))

# Create dataset for each type
pass = full %>% 
    na.omit() %>% 
    filter(typeValue==1) %>%  # keeping just successfull passes
    filter(outcome==1)
touch = full %>% 
    na.omit() %>% 
    filter(isTouch==TRUE) # keeping only Touch == TRUE
shot = full %>% 
    na.omit() %>% 
    filter(typeValue==15 | typeValue==16)

# Create dataset for ggplot2 - touchmap
tomap_touch = touch %>%
    filter(playerId %in% lineup$playerId) %>% 
    group_by(teamId,playerName) %>% 
    summarise(x_avg=mean(x),y_avg=mean(y),n=n())

# Create 3 pass pattern top 5
to_pattern = full %>% filter(playerId %in% lineup$playerId)
players=data.frame()
for(i in c(1:(nrow(to_pattern)-3))){
    if(to_pattern$typeValue[i]==1 & to_pattern$typeValue[i+1]==1 & to_pattern$typeValue[i+2]==1){
        players = rbind(players,data.frame(pattern=paste0(to_pattern$playerName[i],",",to_pattern$playerName[i+1],",",to_pattern$playerName[i+2])))
    }
}

pattern = players %>% 
    group_by(pattern) %>% 
    summarise(n=n()) %>% 
    separate(pattern,into=c("p1","p2","p3"),sep=",",remove=FALSE) %>% 
    arrange(desc(n)) %>% 
    slice(1:5)
pattern$x1=rep(1,5)
pattern$y1=5:1
pattern$x2=rep(1.5,5)
pattern$y2=5:1
pattern$x3=rep(2,5)
pattern$y3=5:1
pattern_tomap <- rbind(pattern %>% 
    select(p=p1,x=x1,y=y1,n,pattern),pattern %>% select(p=p2,x=x2,y=y2,n,pattern),pattern %>% select(p=p3,x=x3,y=y3,n,pattern)) %>%
    separate(p,into=c("firstname","name"),fill="left")



# fucntion to create circle on center
circleFun <- function(center = c(0,0),diameter = 1, npoints = 100){
    r = diameter / 2
    tt <- seq(0,2*pi,length.out = npoints)
    xx <- center[1] + r * cos(tt)
    yy <- center[2] + r * sin(tt)
    return(data.frame(x = xx, y = yy))
}

circle <- circleFun(c(50,50),20,npoints = 100)

# Plot ----------------------------------------------------

# Plot touch map
g_touch <- ggplot(tomap_touch,aes(x=x_avg,y=y_avg)) +
    xlim(0,100) + 
    ylim(0,100)+
    stat_density_2d(aes(fill = ..density..),geom = "tile", contour = FALSE)+
    scale_fill_gradient(low="#74c493",high="#00695c")+
    geom_rect(aes(xmin = 0, xmax = 100, ymin = 0, ymax = 100), fill = NA, colour = "white", size=0.5) +
    geom_rect(aes(xmin = 0, xmax = 50, ymin = 0, ymax = 100), fill = NA, colour = "white", size=0.5) +
    geom_rect(aes(xmin = 17, xmax = 0, ymin = 21, ymax = 79), fill = NA, colour = "white", size=0.5) +
    geom_rect(aes(xmin = 83, xmax = 100, ymin = 21, ymax = 79), fill = NA, colour = "white", size=0.5) +
    geom_rect(aes(xmin = 0, xmax = 6, ymin = 36.8, ymax = 63.2), fill = NA, colour = "white", size=0.5) +
    geom_rect(aes(xmin = 100, xmax = 94, ymin = 36.8, ymax = 63.2), fill = NA, colour = "white", size=0.5) +
    geom_path(data=circle,aes(x=x,y=y),colour="white",size=0.5) +
    geom_point(aes(size=n),shape = 21, colour = "white", fill = TEAM_COLOR, stroke = 1) +
    geom_text(aes(label=playerName),hjust=0, vjust=-1,colour="white",size=6) +
    theme_ipsum_rc()+
    theme(axis.title=element_blank(),axis.text=element_blank(),axis.ticks=element_blank(),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),panel.background = element_blank())+
    theme(legend.position='none')

# 3-pass pattern
g_pattern <- ggplot(pattern_tomap,aes(x,y,group=pattern)) + 
    xlim(0,3) +
    geom_point(aes(size=n),colour = TEAM_COLOR) + 
    scale_size("Count",breaks=c(1:50))+
    geom_line(colour=TEAM_COLOR)+
    geom_text(aes(label=name),hjust=0.5, vjust=2) +
    theme_ipsum_rc() +
    theme(axis.title=element_blank(),axis.text=element_blank(),axis.ticks=element_blank(),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),panel.background = element_blank())



# Save plot
#ggsave(filename = paste0("g_touch_tmp.png"),g_touch,width =14,height=8,dpi=300)
#ggsave(filename = paste0("g_pattern_tmp.png"),g_pattern,width =5,height=8,dpi=300)



# Passnetwork ------------------------------------------------------
# https://briatte.github.io/ggnetwork/
to_pattern = full %>% filter(playerId %in% lineup$playerId)

# Each pass from X to Y
players=data.frame()
for(i in c(1:(nrow(to_pattern)-2))){
    if(to_pattern$typeValue[i]==1 & to_pattern$typeValue[i+1]==1){
        players = rbind(players,data.frame(from=to_pattern$playerName[i],to=to_pattern$playerName[i+1]))
    }
}

meta <- tomap_touch %>% select(name=playerName,x_avg,y_avg,nb_touch=n)
meta2=data.frame(name=meta$name,x_avg=meta$x_avg,y_avg=meta$y_avg,nb_touch=meta$nb_touch)
df <- players %>% 
    group_by(from,to) %>% 
    summarise(n=n()) %>% 
    filter(n>=PASS_NUMBERS)

library(igraph)
g <- graph.data.frame(df, directed = TRUE, vertices = meta2)
lo <- layout.norm(as.matrix(meta2[,2:3]))

#plot.igraph(g,layout = lo)

library(ggnetwork)
g2 <- ggnetwork(g,layout=lo,weights = "n")
map <- ggplot(g2, aes(x = x, y = y, xend = xend, yend = yend)) +
    geom_edges(aes(color = n),size=1,arrow = arrow(length = unit(9, "pt"), type = "closed"),curvature = 0.05) +
    scale_color_gradientn("Passes",colours = c("#b9f6ca","#69f0ae","#00e676","#1b5e20"))+
    geom_nodes(aes(size=nb_touch),shape = 21, colour = "white", fill = TEAM_COLOR, stroke = 1) +
    scale_size("Touches",range = c(0,15),limits=c(1,max(tomap_touch$n)))+
    geom_nodelabel_repel(aes(label = vertex.names),color=TEAM_COLOR,box.padding = unit(1,"lines")) +
    theme_ipsum_rc()+
    theme(axis.title=element_blank(),axis.text=element_blank(),axis.ticks=element_blank(),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),panel.background = element_blank())

ggsave(filename = paste0("img/g_passnetwork_tmp.png"),map,width =14,height=8,dpi=300)