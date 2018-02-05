#lineup

library(rvest)
library(plyr)
library(stringr)
library(ggplot2)
library(ggthemes)
library(hrbrthemes)
library(scales)
library(viridis)
library(extrafont)
library(grid)
library(gridExtra)
library(purrr)
library(dplyr)


# SCRAPPING ---------------------------------
# Attention Permier League / Champions league / FA CUP

#https://www.transfermarkt.com/arsenal-fc_liverpool-fc/aufstellung/spielbericht/2697986
# Return lineup
getLineUp <- function(url,team){
	if(url %>% read_html() %>% html_nodes(xpath='//*[@id="main"]/div[12]/div[1]/div/div[2]/table') %>% is_empty()){

	}else{
		print(url)
		page = url %>% read_html()
		matchday = page %>% html_nodes(xpath='//*[@id="main"]/div[8]/div/div/div[2]/div[3]/p[1]/a[1]') %>% html_text() %>% str_split(.,"\\.",simplify=T) %>% .[[1]] %>% as.numeric()
		if(team==1){
			page = url %>% read_html()
			titu=page %>% html_nodes(xpath='//*[@id="main"]/div[12]/div[1]/div/div[2]/table') %>% html_table(fill=T) %>% nth(1) %>% .$X4 %>% na.omit() %>% as.character() %>% str_replace_all(.,"\\(.*\\)",'') %>% tibble(player=.)
			post_titu = page %>% html_nodes(xpath='//*[@id="main"]/div[12]/div[1]/div/div[2]/table') %>% html_table(fill=T) %>% nth(1) %>% .$X5 %>% na.omit() %>% as.character() %>% str_replace_all(.,",.*","")
			titu$lineup="starting"
			titu$post=post_titu
			bench= page %>% html_nodes(xpath='//*[@id="main"]/div[13]/div[1]/div/div[2]/table')%>% html_table(fill=T) %>% nth(1) %>% .$X4 %>% na.omit() %>% as.character() %>% str_replace_all(.,"\\(.*\\)",'') %>% tibble(player=.)
			post_bench = page %>% html_nodes(xpath='//*[@id="main"]/div[13]/div[1]/div/div[2]/table') %>% html_table(fill=T) %>% nth(1) %>% .$X5 %>% na.omit() %>% as.character() %>% str_replace_all(.,",.*","")
			bench$lineup="bench"
			bench$post = post_bench
			tb=rbind(titu,bench)
		}
		if(team==2){
			page = url %>% read_html()
			titu=page %>% html_nodes(xpath='//*[@id="main"]/div[12]/div[2]/div/div[2]/table') %>% html_table(fill=T) %>% nth(1) %>% .$X4 %>% na.omit() %>% as.character() %>% str_replace_all(.,"\\(.*\\)",'') %>% tibble(player=.)
			post_titu = page %>% html_nodes(xpath='//*[@id="main"]/div[12]/div[2]/div/div[2]/table') %>% html_table(fill=T) %>% nth(1) %>% .$X5 %>% na.omit() %>% as.character() %>% str_replace_all(.,",.*","")
			titu$post=post_titu
			titu$lineup="starting"
			bench= page %>% html_nodes(xpath='//*[@id="main"]/div[13]/div[2]/div/div[2]/table')%>% html_table(fill=T) %>% nth(1) %>% .$X4 %>% na.omit() %>% as.character() %>% str_replace_all(.,"\\(.*\\)",'') %>% tibble(player=.)
			post_bench = page %>% html_nodes(xpath='//*[@id="main"]/div[13]/div[2]/div/div[2]/table') %>% html_table(fill=T) %>% nth(1) %>% .$X5 %>% na.omit() %>% as.character() %>% str_replace_all(.,",.*","")
			bench$lineup="bench"
			bench$post = post_bench
			tb=rbind(titu,bench)
		}

	tb$matchday=matchday
	return(tb)
	}
}

#https://www.transfermarkt.com/arsenal-fc/spielplan/verein/11/plus/0?saison_id=2016
#https://www.transfermarkt.com/chelsea-fc/spielplan/verein/631/plus/0?saison_id=2016
#https://www.transfermarkt.com/ogc-nice/spielplan/verein/417/plus/0?saison_id=2016
# Return url list of match
getMatchUrl <- function(url){
	purrr::map(1:38,function(x) url %>% read_html() %>% html_nodes(xpath=paste0('//*[@id="main"]/div[10]/div[1]/div[6]/div[3]/table/tbody/tr[',x,']/td[10]/a')) %>% html_attr(.,"href") %>% paste0("https://www.transfermarkt.com",.) %>% str_replace_all(.,'index','aufstellung'))
}
# Return home/away (ie 1/2) list
getHomeAwayUrl <- function(url){
	ifelse(purrr::map(1:38,function(x) url %>% read_html() %>% html_nodes(xpath=paste0('//*[@id="main"]/div[10]/div[1]/div[6]/div[3]/table/tbody/tr[',x,']/td[4]')) %>% html_text())=="H",1,2)
}

url='https://www.transfermarkt.com/ogc-nice/spielplan/verein/417/plus/0?saison_id=2016'
all=map2(getMatchUrl(url),getHomeAwayUrl(url),function(a,b)getLineUp(a,b))
all=do.call(rbind,all)
all$player = gsub("[[:space:]]*$","",all$player)

url = "https://www.transfermarkt.com/fc-arsenal/spielplan/verein/11/plus/0?saison_id=2017"
all=map2(getMatchUrl(url),getHomeAwayUrl(url),function(a,b)getLineUp(a,b))
all=do.call(rbind,all)
all$player = gsub("[[:space:]]*$","",all$player)
# PLOT ----------------------------------------------
# all %>% write.csv2(.,file="data/arsenal1718.csv",row.names=FALSE)
# b=unique(all %>% select(player,post)) %>% arrange(desc(post))
# geom_rect(aes(xmin=0,xmax=38,ymin=0,ymax=4), alpha=0.4,fill="#29b6f6") + geom_rect(aes(xmin=0,xmax=38,ymin=4,ymax=15), alpha=0.4,fill="#00bfa5") + geom_rect(aes(xmin=0,xmax=38,ymin=15,ymax=23), alpha=0.4,fill="#64ffda") + geom_rect(aes(xmin=0,xmax=38,ymin=23,ymax=32), alpha=0.4,fill="#ffff00")

# Arsenal
all = read.csv2("data/arsenal_lineup.csv")
# b=unique(all %>% select(player,post)) %>% arrange(desc(post))
image = ggplot() +geom_point(data=all,aes(x=matchday,y=player,color=lineup),size=2) + scale_colour_manual(values=c("#ff8a80","#69f0ae")) + scale_y_discrete(limits=c("Petr Cech", "David Ospina", "Emiliano Martínez","Matt Macey","","Héctor Bellerín","Carl Jenkinson", "Mathieu Debuchy","Nacho Monreal", "Kieran Gibbs", "Laurent Koscielny", "Shkodran Mustafi", "Gabriel Paulista", "Per Mertesacker","Rob Holding", "Calum Chambers","","Granit Xhaka","Aaron Ramsey", "Santi Cazorla","Mesut Özil","Francis Coquelin", "Mohamed Elneny","Jack Wilshere","Jeff Reine-Adelaide","","Alex Oxlade-Chamberlain", "Ainsley Maitland-Niles","Alex Iwobi", "Theo Walcott","Alexis Sánchez","","Olivier Giroud","Danny Welbeck","Lucas Pérez","Chuba Akpom"))+ scale_x_continuous(breaks=c(1,10,20,30,38))+labs(x="Matchday", y="",title="Arsenal Squad Rotation",subtitle="2016-2017 season",caption="by Benoit Pimpaud / @Ben8t",color="") + theme_ipsum_rc()

# Chelsea
all = read.csv2("chelsea_lineup.csv")
# b=unique(all %>% select(player,post)) %>% arrange(desc(post))
ggplot() +geom_point(data=all,aes(x=matchday,y=player,color=lineup),size=2) + scale_colour_manual(values=c("#ff8a80","#69f0ae")) + scale_y_discrete(limits=c("Thibaut Courtois","Asmir Begovic","Eduardo","","David Luiz","Gary Cahill","César Azpilicueta","John Terry","Kurt Zouma","Nathan Aké","Branislav Ivanovic","Marcos Alonso","Victor Moses","Ola Aina","","N'Golo Kanté","Nemanja Matic","Cesc Fàbregas","Ruben Loftus-Cheek","Oscar","","Eden Hazard","Willian","Pedro","","Diego Costa","Michy Batshuayi","Dominic Solanke"))+ scale_x_continuous(breaks=c(1,10,20,30,38))+labs(x="Matchday", y="",title="Chelsea Squad Rotation",subtitle="2016-2017 season",caption="by Benoit Pimpaud / @Ben8t",color="") + theme_ipsum_rc()

# Liverpool
all = read.csv2("liverpool_lineup.csv")
# b=unique(all %>% select(player,post)) %>% arrange(desc(post))
ggplot() +geom_point(data=all,aes(x=matchday,y=player,color=lineup),size=2) + scale_colour_manual(values=c("#ff8a80","#69f0ae")) + scale_y_discrete(limits=c("Simon Mignolet","Loris Karius","Alexander Manninger","","Joel Matip","Dejan Lovren","Ragnar Klavan","James Milner","Alberto Moreno","Joe Gomez","Nathaniel Clyne","Trent Alexander-Arnold","Connor Randall","","Jordan Henderson","Emre Can","Lucas Leiva","Kevin Stewart","Marko Grujic","Georginio Wijnaldum","Adam Lallana","Ben Woodburn","Philippe Coutinho","Harry Wilson","Ovie Ejaria","","Sadio Mané","Roberto Firmino","Daniel Sturridge","Divock Origi","Rhian Brewster"))+ scale_x_continuous(breaks=c(1,10,20,30,38))+labs(x="Matchday", y="",title="Liverpool Squad Rotation",subtitle="2016-2017 season",caption="by Benoit Pimpaud / @Ben8t",color="") + theme_ipsum_rc()

# Manchester Utd
all = read.csv2("manUtd_lineup.csv")
# b=unique(all %>% select(player,post)) %>% arrange(desc(post))
# unique(b$player)
ggplot() +geom_point(data=all,aes(x=matchday,y=player,color=lineup),size=2) + scale_colour_manual(values=c("#ff8a80","#69f0ae")) + scale_y_discrete(limits=c("David de Gea","Sergio Romero","Joel Pereira","Kieran O'Hara","","Eric Bailly","Chris Smalling","Phil Jones","Marcos Rojo","Daley Blind","Axel Tuanzebe","Timothy Fosu-Mensah","Luke Shaw","Demetri Mitchell","Antonio Valencia","Matteo Darmian","Ashley Young","","Michael Carrick","Ander Herrera","Paul Pogba","Marouane Fellaini","Juan Mata","Bastian Schweinsteiger","Morgan Schneiderlin","Scott McTominay","Matthew Willock","Zachary Dearnley","","Henrikh Mkhitaryan","Anthony Martial","Jesse Lingard","Memphis Depay","Josh Harrop","Angel Gomes","","Zlatan Ibrahimovic","Wayne Rooney","Marcus Rashford"))+ scale_x_continuous(breaks=c(1,10,20,30,38))+labs(x="Matchday", y="",title="Manchester United Squad Rotation",subtitle="2016-2017 season",caption="by Benoit Pimpaud / @Ben8t",color="") + theme_ipsum_rc()

# Manchester City
all = read.csv2("manCity_lineup.csv")
# b=unique(all %>% select(player,post)) %>% arrange(desc(post))
# unique(b$player)
ggplot() +geom_point(data=all,aes(x=matchday,y=player,color=lineup),size=2) + scale_colour_manual(values=c("#ff8a80","#69f0ae")) + scale_y_discrete(limits=c("Claudio Bravo","Joe Hart","Willy Caballero","Angus Gunn","","Nicolás Otamendi","Vincent Kompany","John Stones","Aleksandar Kolarov","Pablo Zabaleta","Bacary Sagna" ,"Gaël Clichy","Pablo Maffeo","Tosin Adarabioyo","","Fernandinho","Fernando","Yaya Touré","Fabian Delph","Ilkay Gündogan" ,"David Silva","Kevin De Bruyne","Aleix García","Samir Nasri","","Raheem Sterling","Leroy Sané","Nolito","Jesús Navas","","Sergio Agüero","Gabriel Jesus","Kelechi Iheanacho"))+ scale_x_continuous(breaks=c(1,10,20,30,38))+labs(x="Matchday", y="",title="Manchester City Squad Rotation",subtitle="2016-2017 season",caption="by Benoit Pimpaud / @Ben8t",color="") + theme_ipsum_rc()

# Tottenham
all = read.csv2("tottenham_lineup.csv")
# b=unique(all %>% select(player,post)) %>% arrange(desc(post))
# unique(b$player)
ggplot() +geom_point(data=all,aes(x=matchday,y=player,color=lineup),size=2) + scale_colour_manual(values=c("#ff8a80","#69f0ae")) + scale_y_discrete(limits=c("Hugo Lloris","Michel Vorm","Luke McGee","Pau López","","Toby Alderweireld","Jan Vertonghen","Kevin Wimmer","Ben Davies","Eric Dier","Danny Rose","Kyle Walker","Kieran Trippier","Cameron Carter-Vickers","","Victor Wanyama","Mousa Dembélé","Harry Winks","Ryan Mason","Tom Carroll","Filip Lesniak","","Dele Alli","Christian Eriksen","Heung-Min Son","Moussa Sissoko","Érik Lamela","Georges-Kevin N'Koudou","Josh Onomah","Samuel Shashoua","","Harry Kane","Vincent Janssen"))+ scale_x_continuous(breaks=c(1,10,20,30,38))+labs(x="Matchday", y="",title="Tottenham Squad Rotation",subtitle="2016-2017 season",caption="by Benoit Pimpaud / @Ben8t",color="") + theme_ipsum_rc()

# Nice
all = read.csv2("nice_lineup.csv")
# b=unique(all %>% select(player,post)) %>% arrange(desc(post))
# unique(b$player)
ggplot() + geom_point(data=all,aes(x=matchday,y=player,color=lineup),size=2) + scale_colour_manual(values=c("#ff8a80","#69f0ae")) + scale_y_discrete(limits=c("Yoan Cardinale","Walter Benítez","Mouez Hassen","Simon Pouplin","","Malang Sarr","Paul Baysse","Mathieu Bodmer","Dante","Arnaud Souquet","Maxime Le Marchand","Ricardo Pereira","Dalbert","Olivier Boscagli","Patrick Burner","Gautier Lloris","","Jean Michaël Seri","Wylan Cyprien","Rémi Walter","Vincent Koziello","Mounir Obbadi","Albert Rafetraniaina","","Younès Belhanda","Valentin Eysseric","Arnaud Lusamba","Saïd Benrahma","Julien Vercauteren","Bassem Srarfi","Hicham Mahou","Vincent Marcel","","Mario Balotelli","Alassane Pléa","Anastasios Donis","Alexy Bosetti","Mickaël Le Bihan"))+ scale_x_continuous(breaks=c(1,10,20,30,38))+labs(x="Matchday", y="",title="OGN Nice Squad Rotation",subtitle="2016-2017 season",caption="by Benoit Pimpaud / @Ben8t",color="") + theme_ipsum_rc()


# Arsenal2017-2018
# b=unique(all %>% select(player,post)) %>% arrange(desc(post))
all = read.csv2("data/arsenal1718.csv")
ggplot() +geom_point(data=all,aes(x=matchday,y=player,color=lineup),size=2) + scale_colour_manual(values=c("#ff8a80","#69f0ae")) + scale_y_discrete(limits=c("Petr Cech", "David Ospina", "Emiliano Martínez","Matt Macey","","Héctor Bellerín","Carl Jenkinson", "Mathieu Debuchy","Nacho Monreal", "Kieran Gibbs", "Laurent Koscielny", "Shkodran Mustafi", "Gabriel Paulista", "Per Mertesacker","Rob Holding", "Calum Chambers","","Granit Xhaka","Aaron Ramsey", "Santi Cazorla","Mesut Özil","Francis Coquelin", "Mohamed Elneny","Jack Wilshere","Jeff Reine-Adelaide","","Alex Oxlade-Chamberlain", "Ainsley Maitland-Niles","Alex Iwobi", "Theo Walcott","Alexis Sánchez","","Olivier Giroud","Danny Welbeck","Lucas Pérez","Chuba Akpom"))+ scale_x_continuous(breaks=c(1,10,20,30,38))+labs(x="Matchday", y="",title="Arsenal Squad Rotation",subtitle="2016-2017 season",caption="by Benoit Pimpaud / @Ben8t",color="") + theme_ipsum_rc()



