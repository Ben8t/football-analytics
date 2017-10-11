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

min_played = data %>% group_by(Team,Age.group) %>% summarise(mean_min=sum(Mins),score=first(Classement))
g1 = ggplot(data=min_played,aes(x=reorder(Team,-score),y=mean_min))+
 geom_bar(aes(fill = Age.group),stat = "identity", position = position_stack(reverse = TRUE)) +
 coord_flip() +
 scale_fill_manual("Age range",values = c("#26a69a", "#ffd54f","#ffb74d"))+
 labs(x="", y="Minutes played",title="Minutes played by age",subtitle="2016-2017 season",caption="data from WhoScored \nby Benoit Pimpaud / @Ben8t",color="")+
 theme_ipsum_rc()+
 theme(legend.position = "right")

ggsave("img/Minutes played by age.png",g1,width=10,height=7.3)

gp9 = data %>% group_by(Team,Age.group) %>% summarise(gp9_avg=mean(GoalsPer90),score=first(Classement))
g2 = ggplot(data=gp9,aes(x=reorder(Team,-score),y=gp9_avg))+
 geom_bar(aes(fill = Age.group),stat = "identity", position = position_stack(reverse = TRUE)) +
 coord_flip() +
 scale_fill_manual("Age range",values = c("#26a69a", "#ffd54f","#ffb74d"))+
 labs(x="", y="Goals per 90 minutes",title="Average number of goals per 90 minutes by age",subtitle="2016-2017 season",caption="data from WhoScored \nby Benoit Pimpaud / @Ben8t",color="")+
 theme_ipsum_rc()+
 theme(legend.position = "right")

ggsave("img/Average number of goals per 90 minutes by age.png",g2,width=10,height=7.3)

ap9 = data %>% filter(AssistsPer90<5) %>%group_by(Team,Age.group) %>% summarise(ap9_avg=mean(AssistsPer90),score=first(Classement))
g3 = ggplot(data=ap9,aes(x=reorder(Team,-score),y=ap9_avg))+
 geom_bar(aes(fill = Age.group),stat = "identity", position = position_stack(reverse = TRUE)) +
 coord_flip() +
 scale_fill_manual("Age range",values = c("#26a69a", "#ffd54f","#ffb74d"))+
 labs(x="", y="Assists per 90 minutes",title="Average number of assists per 90 minutes by age",subtitle="2016-2017 season",caption="data from WhoScored \nby Benoit Pimpaud / @Ben8t",color="")+
 theme_ipsum_rc()+
 theme(legend.position = "right")

ggsave("img/Average number of assists per 90 minutes by age.png",g3,width=10,height=7.3)


age = data %>% group_by(Team,Age.group) %>% summarise(nb=n(),score=first(Classement))
g4 = ggplot(data=age,aes(x=reorder(Team,-score),y=nb))+
 geom_bar(aes(fill = Age.group),stat = "identity", position = position_stack(reverse = TRUE)) +
 coord_flip() +
 scale_fill_manual("Age range",values = c("#26a69a", "#ffd54f","#ffb74d"))+
 labs(x="", y="Number of players",title="Age distribution in Premier League",subtitle="2016-2017 season",caption="data from WhoScored \nby Benoit Pimpaud / @Ben8t",color="")+
 theme_ipsum_rc()+
 theme(legend.position = "right")

ggsave("img/Age distribution in Premier League.png",g4,width=10,height=7.3)



