library(tidyverse)
library(readr)

data <- read_csv("data.csv")
sonar_colors <- c("#845EC2", "#D65DB1", "#FF6F91", "#FF9671")
plot <- ggplot(data) +
    geom_bar(stat="identity", aes(x=angle, y=freq, fill=distance)) + 
    coord_polar(start=pi, direction=1) +
    scale_x_continuous(limits=c(-180,180),breaks=seq(-180, 180, 45)) + 
    scale_fill_gradientn(colours=sonar_colors) + 
    theme(legend.background=element_rect(fill=alpha("white", 0.0))) +
    theme_minimal() + 
    theme_ipsum_rc() + 
    theme(axis.title=element_blank(),
          axis.text=element_blank(),
          axis.ticks=element_blank(),
          legend.position="none",
          panel.background=element_blank(),
          panel.grid.minor=element_blank(),
          panel.grid.major = element_blank())