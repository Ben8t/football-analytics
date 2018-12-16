library(dplyr)
library(ggplot2)
library(hrbrthemes)
library(showtext)

font_add("ObjectSans","ObjectSans-Regular.otf")
font_add("ObjectSansHeavy","ObjectSans-Heavy.otf")
showtext_auto()
data = read_csv("/data/data.csv")
graphic <- ggplot() + 
			geom_point(data=data %>% filter(startDate > "2018-07-01") %>% mutate(match_day = match_day - 38), aes(x=match_day, y=player_name, color=lineup), size=2) +
			scale_colour_manual(values=c("#ff8a80","#69f0ae")) + 
			scale_x_continuous(breaks=c(1,5,10,15)) +
			theme_minimal(base_family="ObjectSans", base_size=12) +
			theme(legend.background=element_blank()) +
			theme(legend.key=element_blank()) +
			theme(panel.grid=element_line(color="#cccccc", size=0.2)) +
			theme(panel.grid.major=element_line(color="#cccccc", size=0.2)) +
			theme(panel.grid.minor=element_line(color="#cccccc", size=0.15)) + 
			theme(plot.title= element_text(family="ObjectSans", face="bold", size=15)) +
			theme(legend.text= element_text(family="ObjectSans", size=12)) +
			labs(title="Manchester United Squad Formation", 
				subtitle="Premier League 2018-2019 beginning of season",
				x="Matchday",
				y="") +
			scale_y_discrete(limits=c("Romelu Lukaku", 
				"Marcus Rashford", 
				"Anthony Martial",
				"Alexis Sánchez" ,
				"Jesse Lingard",
				"Juan Mata",
				"Paul Pogba")
			)
		