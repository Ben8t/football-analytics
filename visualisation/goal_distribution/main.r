library(tidyverse)
library(viridis)
library(hrbrthemes)

data <- read_csv("data/data_min_team_against.csv")
adjust <- 3/5
teams_filter <- unique(data$goal_for)
# teams_filter <- c("Liverpool", "Man City", "Arsenal", "Man Utd")

# Goal for
data_goal_for <- data %>% filter(goal_for %in% teams_filter)
plot_goal_for <- ggplot(data_goal_for, aes(x=minute, color=goal_for)) + 
    stat_density(geom="line", position="identity", adjust=adjust) +
    scale_color_viridis_d(option="viridis") + 
    theme_ipsum_rc() + 
    labs(x="Minutes", y="Density",title="Goals distribution",subtitle="",caption="by @Ben8t",color="") +
    theme(text=element_text(colour="white"),
        plot.background=element_rect(fill="black"), 
        axis.text=element_text(colour="white"), 
        legend.text=element_text(colour="white"))

ggsave("img/plot_goal_for.svg", plot_goal_for, width = 20, height = 10, units = "cm")

# Goal against
data_goal_against <- data %>% filter(goal_against %in% teams_filter)
plot_goal_against <- ggplot(data_goal_against, aes(x=minute, color=goal_against)) + 
    stat_density(geom="line", position="identity", adjust=adjust) +
    scale_color_viridis_d(option="viridis") + 
    theme_ipsum_rc() + 
    labs(x="Minutes", y="Density",title="Conceded goals distribution",subtitle="",caption="by @Ben8t",color="") +
    theme(text=element_text(colour="white"),
        plot.background=element_rect(fill="black"), 
        axis.text=element_text(colour="white"), 
        legend.text=element_text(colour="white"))

ggsave("img/plot_goal_against.svg", plot_goal_against, width = 20, height = 10, units = "cm")