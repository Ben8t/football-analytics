# Giroud and Lacazette comparison
library(tidyverse)
library(hrbrthemes)

data <- read.csv("~/Downloads/girlac.csv", dec=",") %>% 
	select(-Total.Passes,-Total.shots,-Left.foot,-Right.foot,-Head,Goals=Goal,`Dribble successful`=Dribble.successful,`Aerial duels won`=Aerial.duels.won,Assists,Player) %>% 
	melt()

ggplot(data,aes(x = reorder(variable, -value),y = value)) + 
    geom_bar(aes(fill = Player),stat = "identity",position = position_stack(reverse = TRUE)) +
 	coord_flip() +
 	scale_fill_manual(values = c("#ef5350", "#64b5f6"))+
 	labs(x="", y="per 90 minutes",title="Olivier Giroud & Alexandre Lacazette statistics",subtitle="2016-2017 season",caption="by Benoit Pimpaud / @Ben8t",color="")+
 	theme_ipsum_rc()