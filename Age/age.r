# age.r

library(rvest)
library(plyr)
library(stringr)
library(ggplot2)
library(ggthemes)
library(hrbrthemes)
library(scales)
library(viridis)
library(extrafont)
library(grid)
library(gridExtra)
library(purrr)
library(dplyr)

data = read.csv("data/data.csv", dec=",")

min_played = data %>% group_by(Team,Age.group) %>% summarise(mean_min=sum(Mins))
ggplot(data=min_played,aes(x=Team,y=mean_min))+
 geom_bar(aes(fill = Age.group),stat = "identity", position = position_stack(reverse = TRUE)) +
 coord_flip() +
 scale_fill_manual(values = c("#26a69a", "#ffd54f","#ffb74d"))+
 theme(legend.position = "bottom")+
 labs(x="", y="Minutes played",title="Minutes played distribution by age",subtitle="2016-2017 season",caption="data from WhoScored \nby Benoit Pimpaud / @Ben8t",color="")+
 theme_ipsum_rc()

gp9 = data %>% group_by(Team,Age.group) %>% summarise(gp9_avg=mean(GoalsPer90))
ggplot(data=gp9,aes(x=Team,y=gp9_avg))+
 geom_bar(aes(fill = Age.group),stat = "identity", position = position_stack(reverse = TRUE)) +
 coord_flip() +
 scale_fill_manual(values = c("#26a69a", "#ffd54f","#ffb74d"))+
 theme(legend.position = "bottom")+
 labs(x="", y="Goals per 90 minutes",title="Average number of goals per 90 minutes by age",subtitle="2016-2017 season",caption="data from WhoScored \nby Benoit Pimpaud / @Ben8t",color="")+
 theme_ipsum_rc()