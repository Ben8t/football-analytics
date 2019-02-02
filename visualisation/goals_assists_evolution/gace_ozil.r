# gace_ozil.r
library(tidyverse)
library(hrbrthemes)
library(reshape2)

# exemple url : https://www.transfermarkt.com/mesut-ozil/leistungsdatenverein/spieler/35664

# data
ozil = data.frame(club=c("Schalke 04","Werder Bremen","Real Madrid","Arsenal"),Goals=c(1*90/2268,16*90/8279,27*90/11377,32*90/13810),Assists=c(5*90/2268,54*90/8279,81*90/11377,57*90/13810))

# reshape for ggplot barchart
ozil.dodge = melt(ozil)

# plot
ggplot(data=ozil.dodge,aes(x=club)) + geom_bar(aes(y=value,fill=variable),stat="identity",position=position_dodge()) + scale_fill_manual(values=c("#1de9b6", "#40c4ff")) + scale_x_discrete(limits=c("Schalke 04","Werder Bremen","Real Madrid","Arsenal")) +labs(x="", y="per 90 minutes",title="Mesut Ozil goals and assists evolution",subtitle="",caption="by Benoit Pimpaud / @Ben8t",color="") + theme_ipsum_rc()
