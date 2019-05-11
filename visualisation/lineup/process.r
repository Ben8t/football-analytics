library(tidyverse)
library(ggplot2)
library(hrbrthemes)
library(showtext)

data <- read_csv("data/data.csv")

data_order <- data %>% 
	group_by(player_name, position) %>% 
	summarise(n=n()) %>% 
	filter(position=="tit") %>% 
	select(player_name, n)

graphic_data <- merge(data, data_order) %>% 
	arrange(desc(n))

graphic <- ggplot() + 
			geom_point(data=graphic_data, aes(x=matchday, y=reorder(player_name,desc(n)), color=position), size=2) +
			scale_colour_manual(values=c("#ff8a80","#69f0ae")) + 
			scale_x_continuous(breaks=c(1,5,10,15,20,25,30,35,38)) +
			theme_minimal() +
			theme(legend.background=element_blank()) +
			theme(legend.key=element_b	lank()) +
			theme(panel.grid=element_line(color="#cccccc", size=0.2)) +
			theme(panel.grid.major=element_line(color="#cccccc", size=0.2)) +
			theme(panel.grid.minor=element_line(color="#cccccc", size=0.15)) + 
			theme(plot.title= element_text(family="ObjectSans", face="bold", size=15)) +
			theme(legend.text= element_text(family="ObjectSans", size=12)) +
			labs(title="Manchester City Squad Formation", 
				subtitle="Premier League 2018-2019 beginning of season",
				x="Matchday",
				y="")
		