library(readr)
library(zoo)
library(ggplot2)
library(dplyr)
library(ggthemes)
library(hrbrthemes)


data <- read_csv("data/all_xg.csv")

game_id <- "000be874ddf1f5436cb38cfd49fc03c3"

game_data <- data %>% 
    filter(game_id=="000be874ddf1f5436cb38cfd49fc03c3") %>% 
    select(team_id, minute, expected_goal, is_goal)

plot_data <- game_data %>% 
    group_by(team_id) %>% 
    arrange(minute) %>% 
    mutate(cumsum_xg=cumsum(expected_goal), cumsum_goal=cumsum(is_goal))

ggplot() + 
    geom_step(data=plot_data, aes(x=minute, y=cumsum_xg, color=factor(team_id))) + 
    geom_step(data=plot_data, aes(x=minute, y=cumsum_goal, color=factor(team_id)), linetype=2) +
    theme_ipsum_rc() +
    theme(
        plot.title = element_text(size=35),
        text = element_text(colour="white"),
        axis.text.y = element_text(colour="white"),
        axis.text.x = element_text(colour="white"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.background = element_rect(fill = "black")) +
    theme(axis.text.x = element_text(angle = 0, hjust = 1))