# start_evo.r
library(tidyverse)
library(hrbrthemes)
library(reshape2)


# data
delph = data.frame(season=c("Aston Villa 09/10","Aston Villa 10/11","Aston Villa 11/12","Aston Villa 12/13","Aston Villa 13/14","Aston Villa 14/15","Manchester City 15/16","Manchester City 16/17"),start=c(8,7,11,24,34,28,17,7))

# reshape for ggplot barchart
delph.dodge = melt(delph)

# plot
ggplot(data=delph.dodge,aes(x=season)) + geom_bar(aes(y=value,fill=variable),stat="identity",position=position_dodge()) + scale_fill_manual(values=c("#1de9b6")) + scale_x_discrete(limits=c("Aston Villa 09/10","Aston Villa 10/11","Aston Villa 11/12","Aston Villa 12/13","Aston Villa 13/14","Aston Villa 14/15","Manchester City 15/16","Manchester City 16/17")) +labs(x="", y="Games",title="Fabian Delph games evolution",subtitle="",caption="by Benoit Pimpaud / @Ben8t",color="") + theme_ipsum_rc() + theme(legend.position='none') + theme(axis.text.x = element_text(angle = 45, hjust = 1))
