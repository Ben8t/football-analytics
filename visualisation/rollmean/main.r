library(readr)
library(zoo)
library(ggplot2)
library(dplyr)
library(hrbrthemes)


raw_data <- read_csv("wolves_xg_xgc.csv")
id = 161
subtitle = "Wolverhampton in Premier League"
rolling = 15

data <- raw_data %>% 
    mutate(team=ifelse(team_id==id, "xG", "xGC"), id=row_number()) %>% 
    select(startDate, team, xG)

grouped_data <- data %>% 
    group_by(startDate, team) %>% 
    summarise(xg=sum(xG)) %>% as.data.frame() %>%
    mutate(date=format(as.Date(startDate), format="%Y-%m-%d"))
grouped_data$id <- rep(1:(nrow(grouped_data)/2), each=2)

ggplot() + 
    geom_line(data=grouped_data %>% filter(team=="xG"), aes(x=id, y=rollmean(xg, rolling, na.pad=TRUE), color=team)) +
    geom_point(data=grouped_data %>% filter(team=="xG"), aes(x=id, y=rollmean(xg, rolling, na.pad=TRUE), , color=team)) +
    scale_color_manual(values=c("#56FFAE", "#FCA337")) +
    geom_line(data=grouped_data %>% filter(team=="xGC"), aes(x=id, y=rollmean(xg, rolling, na.pad=TRUE), color=team)) +
    geom_point(data=grouped_data %>% filter(team=="xGC"), aes(x=id, y=rollmean(xg, rolling, na.pad=TRUE), color=team)) + 
    geom_vline(xintercept=39, color="white", linetype="dashed") +
    geom_text(aes(x=39, y=0.3, label="\nchange in season"), colour="white", angle=90, size=3)+
    geom_vline(xintercept=77, color="white", linetype="dashed") +
    geom_text(aes(x=77, y=0.3, label="\nchange in season"), colour="white", angle=90, size=3)+
    geom_vline(xintercept=115, color="white", linetype="dashed") +
    geom_text(aes(x=115, y=0.3, label="\nchange in season"), colour="white", angle=90, size=3)+
    scale_x_continuous(breaks=seq(1,nrow(grouped_data)/2, 5), limits=c(5,nrow(grouped_data)/2), labels=unique(grouped_data$date)[seq(1,nrow(grouped_data)/2, 5)]) +
    scale_y_continuous(breaks=c(0,0.5,1,1.5,2,2.5,3), limits=c(0,3)) +
    labs(x="", y="xG/xGC",title="xG & xGC rolling averages",subtitle=subtitle,caption=paste0(rolling, " games rolling averages\nby @Ben8t"),color="") +
    theme_ipsum_rc() +
    theme(
        plot.title = element_text(size=35),
        text = element_text(colour="white"),
        axis.text.y = element_text(colour="white"),
        axis.text.x = element_text(colour="white"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.background = element_rect(fill = "#2162AA")) +
    theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        axis.line.x = element_line(color="white"),
        axis.line.y = element_line(color="white"),
        axis.ticks.y = element_line(color="white"),
    )
