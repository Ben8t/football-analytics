library(tidyverse)
library(viridis)
library(hrbrthemes)
library(gghighlight)

data <- read_csv("data/data_min_team.csv")
adjust <- 1
teams_filter <- unique(data$goal_for)
# teams_filter <- c("Liverpool", "Man City", "Arsenal", "Man Utd")

# Goal for
data_goal_for <- data %>% filter(goal_for %in% teams_filter)
plot_goal_for <- ggplot(data_goal_for, aes(x=minute, color=goal_for)) + 
    stat_density(geom="line", position="identity", adjust=adjust) +
    scale_color_viridis_d(option="viridis") + 
    # gghighlight(goal_for=="Man City" || goal_for=="Liverpool") + 
    gghighlight(goal_for=="Huddersfield" || goal_for=="Fulham" || goal_for=="Cardiff") + 
    # gghighlight(goal_for=="Arsenal" || goal_for=="Tottenham" || goal_for=="Man City" || goal_for=="Man Utd" || goal_for=="Liverpool" || goal_for=="Chelsea") + 
    theme_ipsum_rc() + 
    labs(x="Minutes", y="Density",title="Goals distribution",subtitle="",caption="by @Ben8t",color="") +
    theme(text=element_text(colour="white"),
        plot.background=element_rect(fill="black"), 
        axis.text=element_text(colour="white"), 
        legend.text=element_text(colour="white"))

ggsave("img/plot_goal_for.svg", plot_goal_for, width = 20, height = 15, units = "cm")

# Goal against
data_goal_against <- data %>% filter(goal_against %in% teams_filter)
plot_goal_against <- ggplot(data_goal_against, aes(x=minute, color=goal_against)) + 
    stat_density(geom="line", position="identity", adjust=adjust) +
    scale_color_viridis_d(option="viridis") + 
    # gghighlight(goal_against=="Man City" || goal_against=="Liverpool") + 
    gghighlight(goal_against=="Huddersfield" || goal_against=="Fulham" || goal_against=="Cardiff") + 
    # gghighlight(goal_against=="Arsenal" || goal_against=="Tottenham" || goal_against=="Man City" || goal_against=="Man Utd" || goal_against=="Liverpool" || goal_against=="Chelsea") + 
    theme_ipsum_rc() + 
    labs(x="Minutes", y="Density",title="Conceded goals distribution",subtitle="",caption="by @Ben8t",color="") +
    theme(text=element_text(colour="white"),
        plot.background=element_rect(fill="black"), 
        axis.text=element_text(colour="white"), 
        legend.text=element_text(colour="white"))

ggsave("img/plot_goal_against.svg", plot_goal_against, width = 20, height = 15, units = "cm")