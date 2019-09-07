library(readr)
library(ggplot2)
library(dplyr)
library(hrbrthemes)

all_xg <- read_csv("data/all_xg.csv")

test = all_xg %>% 
    filter(game_id == "27f2d04e1caeb9b665c06cc534a73055") %>% 
    select(event_id, game_id, team_id, player_id, minute, is_goal, expected_goal) %>%
    group_by(team_id) %>%
    mutate(cum_goal=cumsum(is_goal), cum_xg=cumsum(expected_goal)) %>% 
    mutate(xg_plus=cum_goal - cum_xg)

ggplot() + 
    geom_step(data=test, aes(x=minute, y=xg_plus, color=factor(team_id))) +
    geom_hline(yintercept=0, color="black", linetype="dashed") + 
    geom_text(aes(x=5, y=0.1, label="Upper you are good"), colour="black", angle=0, size=3)+
    geom_hline(yintercept=-1, color="black", linetype="dashed") + 
    geom_text(aes(x=5, y=-0.9, label="Lower you are bad"), colour="black", angle=0, size=3)+
    labs(x="", y="Goal - xG",title="Contextualized Expected Goal",subtitle="",caption="by @Ben8t",color="") +
    theme_ipsum_rc() +
    theme(
        plot.title = element_text(size=35),
        text = element_text(colour="black"),
        axis.text.y = element_text(colour="black"),
        axis.text.x = element_text(colour="black"),
        plot.background = element_rect(fill = "white")) +
    theme(axis.text.x = element_text(angle = 0, hjust = 1))
