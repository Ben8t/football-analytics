library(tidyverse)
library(viridis)
library(hrbrthemes)
library(gghighlight)


data <- read_csv("data/average_time_fielded_player_20182019.csv")

plot <- ggplot(data, aes(x=average_minute, y=position)) + 
    geom_smooth(method="glm", formula="y~poly(x, 2)", fill="gray", color="#FC3C6C") +
    geom_point(aes(color=-position)) + 
    geom_text(aes(label=home_team_name), hjust=-0.1, vjust=-0.1, size=2, color="white", family="roboto") +
    scale_color_viridis(option="viridis") +
    theme_ipsum_rc() +
    labs(x="Average minute of substitution", y="League Position",title="Minute of substitution",subtitle="Premier League 2018-2019",caption="by @Ben8t",color="") +
    theme(text=element_text(colour="white"),
        plot.background=element_rect(fill="black"), 
        axis.text=element_text(colour="white"), 
        legend.text=element_text(colour="white"),
        legend.position="None")

ggsave("img/plot20182019.png", plot, width = 20, height = 12, units = "cm")
