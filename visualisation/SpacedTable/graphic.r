# graphic.r

library(ggplot2)
library(dplyr)
library(hrbrthemes)


table = read.csv("data/premier_league_table.csv") %>% 
	select(Team,Pts) %>% 
	mutate(Pos=row_number()) %>%
	mutate(Place=ifelse(Pos<=4,"Champions League", ifelse(Pos<=6, "Europa League", ifelse(Pos>17, "Relegation", "Premier League")))) %>%
	mutate(seg_x=0.99, seg_xend=1.01, seg_y=Pts, seg_yend=Pts)

data = table %>% 
	group_by(Pts) %>% 
	mutate(Team = paste0(Team, collapse = ", "))

graph = ggplot(data, aes(x=1, y=Pts)) + 
	geom_line(color="#636e72") +
	geom_segment(aes(x=seg_x,xend=seg_xend,y=seg_y,yend=seg_yend), color="#636e72") +
	geom_point(aes(color=Place)) + 
	geom_text(aes(label=Team, color=Place),hjust=1, x=0.98, show.legend = FALSE) + 
	geom_text(aes(label=Pts, color=Place),hjust=0, x=1.02, show.legend = FALSE) + 
	scale_colour_manual(values=c("#0984e3","#F1AF41","#2d3436","#d63031")) +
	scale_x_continuous(limits=c(0.40,1.20)) +
	scale_y_continuous(limits=c(min(data$Pts),max(data$Pts))) +
	labs(x="", y="",title="Spaced Table",subtitle="",caption="by @Ben8t",color="") + 
	theme_ipsum_rc() + 
	theme(axis.title.x=element_blank(),
		axis.text.x=element_blank(),
		axis.ticks.x=element_blank(), 
		axis.title.y=element_blank(),
		axis.text.y=element_blank(),
		axis.ticks.y=element_blank(), 
		panel.grid.major=element_blank(),
		panel.grid.minor=element_blank(),
		legend.position = c(0.95, 0.5))
	
ggsave(filename = "img/tmp.png", graph, width=5.5, height=10, dpi=300)

