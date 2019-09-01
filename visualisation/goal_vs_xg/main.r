library(readr)
library(zoo)
library(ggplot2)
library(dplyr)
library(ggthemes)
library(hrbrthemes)


raw_data <- read_csv("data/all_xg.csv")
id = 32
subtitle = "Manchester United - 2015 to 2019 Premier League season"

data <- raw_data %>%
    filter(team_id==id) %>%
    group_by(startDate) %>%
    summarise(goal=sum(is_goal, na.rm=TRUE), xg=sum(expected_goal, na.rm=TRUE)) %>%
    mutate(cummean_goal=cummean(goal), cummean_xg=cummean(xg))


grouped_data <- data %>%
    mutate(date=format(as.Date(startDate), format="%Y-%m-%d"))
grouped_data$id <- seq(1, nrow(grouped_data))

ggplot() + 
    geom_line(data=grouped_data, aes(x=id, y=rollmean(xg, 5, na.pad=TRUE)), color="#56FFAE") +
    geom_point(data=grouped_data, aes(x=id, y=rollmean(xg, 5, na.pad=TRUE)), color="#56FFAE") +
    geom_line(data=grouped_data, aes(x=id, y=rollmean(goal, 5, na.pad=TRUE)), color="#FCA337") +
    geom_point(data=grouped_data, aes(x=id, y=rollmean(goal, 5, na.pad=TRUE)), color="#FCA337") + 
    geom_vline(xintercept=39, color="white", linetype="dashed") +
    geom_text(aes(x=39, y=0.3, label="\nchange in season"), colour="white", angle=90, size=3)+
    geom_vline(xintercept=77, color="white", linetype="dashed") +
    geom_text(aes(x=77, y=0.3, label="\nchange in season"), colour="white", angle=90, size=3)+
    geom_vline(xintercept=115, color="white", linetype="dashed") +
    geom_text(aes(x=115, y=0.3, label="\nchange in season"), colour="white", angle=90, size=3)+
    geom_vline(xintercept=153, color="white", linetype="dashed") +
    geom_text(aes(x=153, y=0.3, label="\nchange in season"), colour="white", angle=90, size=3)+
    scale_x_continuous(breaks=seq(1,nrow(grouped_data), 4), labels=grouped_data$date[seq(1,nrow(grouped_data), 4)]) +
    labs(x="", y="Average xG and goals",title="xG and goals average",subtitle=subtitle,caption="by @Ben8t",color="") +
    theme_ipsum_rc() +
    theme(
        plot.title = element_text(size=35),
        text = element_text(colour="white"),
        axis.text.y = element_text(colour="white"),
        axis.text.x = element_text(colour="white"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.background = element_rect(fill = "#2162AA")) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
