# map_scrape.r
# WhoScored : copy(JSON.stringify(matchCentreData));

library(tidyverse)
library(hrbrthemes)
library(jsonlite)

data = jsonlite::fromJSON("test.json")

event = data.frame(id=data$events$id,eventId=data$events$eventId,minute=data$events$minute,second=data$events$second,teamId=data$events$teamId,playerId=data$events$playerId,x=data$events$x,y=data$events$y,typeValue=data$events$type$value,typeDisplayName=data$events$type$displayName,period=data$events$period$value,isTouch=data$events$isTouch,outcome=data$events$outcomeType$value)

player= data$playerIdNameDictionary %>% t %>% as.data.frame() %>% t %>% as.data.frame() %>% tibble::rownames_to_column() %>% select(playerName=V1,playerId=rowname) %>% mutate(playerId=as.numeric(playerId),playerName=unlist(playerName))

home_lineup = data$home$formations$playerIds[[1]] %>% as.data.frame() %>% select(.,playerId=.) %>% slice(1:11)
away_lineup = data$away$formations$playerIds[[1]] %>% as.data.frame() %>% select(.,playerId=.) %>% slice(1:11)

full = left_join(event,player,by=c("playerId"))


pass = full %>% na.omit() %>% filter(typeValue==1) %>% filter(outcome==1)
touch = full %>% na.omit() %>% filter(isTouch==TRUE)

tomap = touch %>%
	filter(playerId %in% away_lineup$playerId) %>% 
	group_by(teamId,playerName) %>% 
	summarise(x_avg=mean(x),y_avg=mean(y),n=n())



circleFun <- function(center = c(0,0),diameter = 1, npoints = 100){
    r = diameter / 2
    tt <- seq(0,2*pi,length.out = npoints)
    xx <- center[1] + r * cos(tt)
    yy <- center[2] + r * sin(tt)
    return(data.frame(x = xx, y = yy))
}


circle <- circleFun(c(50,50),20,npoints = 100)


g <- ggplot(tomap,aes(x=x_avg,y=y_avg)) +
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
    geom_point(aes(size=n),shape = 21, colour = "white", fill = "#00bfa5", stroke = 1) +
    geom_text(aes(label=playerName),hjust=0, vjust=-1,colour="black") +
    theme_ipsum_rc()+
    theme(axis.title=element_blank(),axis.text=element_blank(),axis.ticks=element_blank(),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),panel.background = element_blank())+
    labs(x="", y="",title="Touchmap \nArsenal away at Stoke City",subtitle="Premier League - 19/08/2017",caption="Dot size : touches - Dot position : average touch position \n \n by Benoit Pimpaud / @Ben8t",color="") +theme(legend.position='none')





