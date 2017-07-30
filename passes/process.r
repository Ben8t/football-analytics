# scrapeFourfourtwo.r
library(rvest)
library(plyr)
library(stringr)
library(ggplot2)
library(ggthemes)
library(scales)
library(viridis)
library(extrafont)
library(grid)
library(gridExtra)
library(dplyr)

#############
# SCRAPPING #
#############

# get all match url
url="https://www.fourfourtwo.com/statszone/results/8-2016"
listMatch = url %>% read_html() %>% html_nodes(".link-to-match a") %>% html_attr("href")
pb = txtProgressBar(min = 0, max = length(listMatch), style = 3)
tic=0
stats = data.frame()
passesCombinations = data.frame()
for(m in listMatch){
	url = paste0("https://www.fourfourtwo.com",m)
	page = url %>% read_html()
	#get variable
	id = str_split(url,"/")[[1]][7]
	place_date = page %>% html_nodes(xpath='//*[@id="match-head"]/div[1]/text()') %>% nth(1) %>% str_replace_all(., "[\\s\\n]" , "")
	homeTeam = page %>% html_nodes(xpath='//*[@id="match-head"]/div[1]/div/span[1]') %>% html_text() %>% str_replace_all(.,"[\\s\\n]","")
	awayTeam = page %>% html_nodes(xpath='//*[@id="match-head"]/div[1]/div/span[3]') %>% html_text() %>% str_replace_all(.,"[\\s\\n]","")
	score = page %>% html_nodes(xpath='//*[@id="match-head"]/div[1]/div/span[2]') %>% html_text() %>% str_replace_all(.,"[\\s\\n]","")
	goalHome = str_split(score,"-")[[1]][1] %>% as.numeric()
	goalAway = str_split(score,"-")[[1]][2] %>% as.numeric()
	possessionHome = page %>% html_nodes(xpath='//*[@id="summary_possessions"]/svg/text[1]') %>% html_text() %>% str_replace_all(.,"[\\s\\n %]","") %>% as.numeric()
	possessionAway = page %>% html_nodes(xpath='//*[@id="summary_possessions"]/svg/text[2]') %>% html_text() %>% str_replace_all(.,"[\\s\\n %]","") %>% as.numeric()
	passesCompletedHome = page %>% html_nodes(xpath='//*[@id="summary_passes"]/svg/text[1]') %>% html_text() %>% str_replace_all(.,"[\\s\\n]","") %>% as.numeric()
	passesCompletedAway = page %>% html_nodes(xpath='//*[@id="summary_passes"]/svg/text[2]') %>% html_text() %>% str_replace_all(.,"[\\s\\n]","") %>% as.numeric()
	cornersHome = page %>% html_nodes(xpath='//*[@id="summary_corners"]/svg/text[1]') %>% html_text() %>% str_replace_all(.,"[\\s\\n]","") %>% as.numeric()
	cornersAway = page %>% html_nodes(xpath='//*[@id="summary_corners"]/svg/text[2]') %>% html_text() %>% str_replace_all(.,"[\\s\\n]","") %>% as.numeric()
	atk3rdPassesHome = page %>% html_nodes(xpath='//*[@id="summary_attacking"]/svg/text[1]') %>% html_text() %>% str_replace_all(.,"[\\s\\n]","") %>% as.numeric()
	atk3rdPassesAway = page %>% html_nodes(xpath='//*[@id="summary_attacking"]/svg/text[2]') %>% html_text() %>% str_replace_all(.,"[\\s\\n]","") %>% as.numeric()
	shotsHome = page %>% html_nodes(xpath='//*[@id="summary_shots"]/svg/text[1]') %>% html_text() %>% str_replace_all(.,"[\\s\\n]","") %>% as.numeric()
	shotsAway = page %>% html_nodes(xpath='//*[@id="summary_shots"]/svg/text[2]') %>% html_text() %>% str_replace_all(.,"[\\s\\n]","") %>% as.numeric()
	foulsHome = page %>% html_nodes(xpath='//*[@id="summary_fouls"]/svg/text[1]') %>% html_text() %>% str_replace_all(.,"[\\s\\n]","") %>% as.numeric()
	foulsAway = page %>% html_nodes(xpath='//*[@id="summary_fouls"]/svg/text[2]') %>% html_text() %>% str_replace_all(.,"[\\s\\n]","") %>% as.numeric()
	passTable = page %>% html_nodes(xpath='//*[@id="table"]/div/table') %>% html_table() %>% nth(1) %>% unite(p_to_p,X2,X3,X4) %>% mutate(id=id) %>% select(id,p_to_p,nbPass=X5)
	passesCombinations = rbind(passesCombinations,passTable)
	stats = rbind(stats,data.frame(id,url,place_date,homeTeam,awayTeam,score,goalHome,goalAway,possessionHome,possessionAway,passesCompletedHome,passesCompletedAway,cornersHome,cornersAway,atk3rdPassesHome,atk3rdPassesAway,shotsHome,shotsAway,foulsHome,foulsAway))
	tic=tic+1
	setTxtProgressBar(pb,tic)
}

#################
# VISUALIZATION #
#################

#fft_passesCombination <- read.csv("data/fft_passesCombination.csv", sep=";")
#stats <- read.csv("data/fft_scrape.csv", sep=";")

#################################
# PLAYER TOP PASSES COMBINATION #
#################################
player = "Koscielny"
playerPass = fft_passesCombination %>% filter(grepl(paste0(player,"_"),p_to_p)) %>% group_by(p_to_p) %>% summarise(sum=mean(nbPass)) %>% arrange(desc(sum))
color = c("#ffc900","#524fff","#727272","#c0c0c0","#000000","#ff6e93","#e31a1c","#80eca8","#003366","#ffe7b9","#1e5d64","#00ba99","#10e4f9","#f67d6a","#ffa832")
h1 = ggplot(playerPass,aes(x=p_to_p,y=sum,fill=p_to_p))+ geom_col()  + coord_polar(theta = "x") + theme_hc()+ scale_colour_hc() + 
scale_fill_manual(values=color) + theme(legend.position="right") + theme(text=element_text(family="Lato"),plot.title = element_text(hjust = 0.5),axis.title.x=element_blank(),axis.text.x=element_blank(),axis.ticks.x=element_blank()) + ylab("Average number of passes") + ggtitle(paste("Best combinations from",player,"to a teammate")) + theme(legend.title = element_blank())

player = "Henderson"
playerPass = fft_passesCombination %>% filter(grepl(paste0(player,"_"),p_to_p)) %>% group_by(p_to_p) %>% summarise(sum=mean(nbPass)) %>% arrange(desc(sum))
color = c("#ffc900","#524fff","#727272","#c0c0c0","#000000","#ff6e93","#e31a1c","#80eca8","#003366","#ffe7b9","#1e5d64","#00ba99","#10e4f9","#f67d6a","#ffa832")
h2 = ggplot(playerPass,aes(x=p_to_p,y=sum,fill=p_to_p))+ geom_col()  + coord_polar(theta = "x") + theme_hc()+ scale_colour_hc() + 
scale_fill_manual(values=color) + theme(legend.position="right") + theme(text=element_text(family="Lato"),plot.title = element_text(hjust = 0.5),axis.title.x=element_blank(),axis.text.x=element_blank(),axis.ticks.x=element_blank()) + ylab("Average number of passes") + ggtitle(paste("Best combinations from",player,"to a teammate")) + theme(legend.title = element_blank())

grid.arrange(h1,h2)

##########
# CORNER #
##########
getCornerHomePerMatch <- function(data,team){
	cornersHome = data %>% filter(homeTeam==team) %>% select(cornersHome) %>% sum(.)
	return((cornersHome)/19)
}

getCornerAwayPerMatch <- function(data,team){
	cornersAway = data %>% filter(homeTeam==team) %>% select(cornersAway) %>% sum(.)
	return((cornersAway)/19)
}

corner_data = data.frame(team=unique(stats$homeTeam),cornerPerHomeMatch=sapply(unique(stats$homeTeam),function(x)getCornerHomePerMatch(stats,x)),cornerPerAwayMatch=sapply(unique(stats$awayTeam),function(x)getCornerAwayPerMatch(stats,x)))
j1 = ggplot(corner_data,aes(x=team,y=cornerPerHomeMatch,fill=cornerPerHomeMatch)) + geom_col() + coord_polar(theta="x") +theme_hc()+ scale_fill_viridis() + theme(legend.position="right") + theme(text=element_text(family="Lato"),plot.title = element_text(hjust = 0.5),axis.title.x=element_blank(),axis.ticks.x=element_blank()) + ylab("") + ggtitle("Corners per home match") + theme(legend.title = element_blank())

j2 = ggplot(corner_data,aes(x=team,y=cornerPerAwayMatch,fill=cornerPerAwayMatch)) + geom_col() + coord_polar(theta="x") +theme_hc()+ scale_fill_viridis() + theme(legend.position="right") + theme(text=element_text(family="Lato"),plot.title = element_text(hjust = 0.5),axis.title.x=element_blank(),axis.ticks.x=element_blank()) + ylab("") + ggtitle("Corners per away match") + theme(legend.title = element_blank())

grid.arrange(j1,j2)


library(tidyr)
data = gather(corner_data,cornerPerHomeMatch,cornerPerAwayMatch,-team) %>% select(team,type=cornerPerHomeMatch,value=cornerPerAwayMatch)
ggplot(data,aes(x=team,y=value,fill=type)) + geom_bar(position = "dodge",stat="identity") + scale_fill_manual(values=c("#0091ea","#00bfa5")

########################
# ATTACKING 3RD PASSES #
########################

getMean3rdPasses <- function(data,team){
	home = data %>% filter(homeTeam==team) %>% select(atk3rdPassesHome) %>% sum(.)
	away = data %>% filter(awayTeam==team) %>% select(atk3rdPassesAway) %>% sum(.)
	return((home+away)/38)
}

df_3rdPasses=data.frame(do.call(rbind,lapply(as.character(unique(stats$homeTeam)),function(x) return(c(x,round(getMean3rdPasses(stats,x),digits=0)))))) %>% select(Team=X1,mean3rdPasses=X2) %>% mutate(Team=as.character(Team),mean3rdPasses=as.numeric(levels(mean3rdPasses))[mean3rdPasses]) %>% arrange(desc(mean3rdPasses))

color = c("#D00027","#EF0107","#5CBFEB","#034694","#DA020E","#001C58","#000000","#274488","#FFC20E","#000000","#1B458F","#E03A3E","#0053A0","#60223B","#8CCCE5","#FF7E00","#EA2D04","#FBEE23","#091453","#EA2D04")

df_3rdPasses$color = color

g = ggplot(df_3rdPasses,aes(x=Team,y=mean3rdPasses,fill=mean3rdPasses)) + geom_bar(stat="identity") + scale_fill_gradient(low = "#ffebee", high = "#b71c1c")+ theme_hc()+ scale_x_discrete(limits=df_3rdPasses$Team) + scale_y_continuous(name="Average of 3 passes or more",limits=c(0,200),expand=c(0,0)) + theme(text=element_text(family="Lato"),plot.title = element_text(hjust = 0.5),axis.title.x=element_blank(),axis.ticks.x=element_blank()) + ggtitle("Average number of attack with more than 3 passes") + theme(legend.title = element_blank()) + theme(axis.text.x = element_text(angle = 45, hjust = 1)) + theme(legend.position="none")



