# acp.r

library(tidyverse)
library(FactoMineR)
library(hrbrthemes)

ozil_pca <- read.csv("ozil_pca.csv", dec=",") %>% select(-Apps,-Mins)

df.pca <- PCA(X=ozil_pca,quali.sup = 1)

df.coord=df.pca$ind$coord %>% as.data.frame() %>% select(DefensiveImplication=Dim.1,AttackingIntention=Dim.2)
df.coord$Player=ozil_pca$Player
df.coord = df.coord %>% separate(Player, into=c("Name","Family"))
df.coord$Family[2] = "De Bruyne"
df.coord$Family[12] = "Pedro"
df.coord$Family[28] = "Evandro"

ggplot(data=df.coord,aes(x=DefensiveImplication,y=AttackingIntention)) + 
	xlim(-4,5)+
	ylim(-3,6)+
	geom_point(aes(colour=Family)) +
	geom_text(aes(label=Family),hjust=0, vjust=0,colour="black")+
	theme_ipsum_rc()+
    theme(axis.title=element_blank(),axis.text=element_blank(),axis.ticks=element_blank())+
    labs(x="DefensiveImplication", y="AttackingIntention",title="Mesut Ozil statistics comparison",subtitle="Premier League 2016/2017",caption='PCA analysis with mutliple variables such as shots, goals, assists, tackles won, etc.... all recorded as "per 90mins".\nby Benoit Pimpaud / @Ben8t',color="")



