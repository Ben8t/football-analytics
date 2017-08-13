library(dplyr)
library(rvest)
library(readr)
library(stringr)


#One shot -------------
# url="http://www.rotowire.com/soccer/player.htm?id=16664"
# page = url %>% read_html()
# table = page %>% html_nodes(xpath='/html/body/div[3]/div[9]/table[1]') %>% html_table() %>% nth(1)
# print(table)

urls = read_delim("link_player_PremierLeague.csv",",")
#print(urls$URL)

data=data.frame()
for(u in urls$URL){
	tmp = data.frame()
	print(u)
	page = u %>% read_html()
	Sys.sleep(5)
	player = page %>% html_nodes(xpath='/html/body/div[3]/div[1]/div[2]/div[1]/p[1]') %>% html_text()
	club = page %>% html_nodes(xpath='/html/body/div[3]/div[1]/div[2]/div[1]/p[2]/span/text()') %>% html_text()
	age = page %>% html_nodes(xpath='/html/body/div[3]/div[1]/div[2]/div[1]/p[2]/text()') %>% html_text() %>% str_split(.," ") %>% nth(1) %>% nth(1) %>% substring(.,1,2)
	position = page %>% html_nodes(xpath='/html/body/div[3]/div[1]/div[2]/div[1]/p[2]/text()') %>% html_text() %>% str_split(.," ") %>% nth(1) %>% nth(2)
	if((position!="Defender" & position!="Midfielder" & position!="Midfielder" & position!="Forward/Midfielder" & position!="Forward" )| page %>% html_nodes(".mlb-player-basicstatsbox > table") %>% nth(3) %>% html_nodes('td') %>% html_text() == "No stats available for this player."){
		next
	}else{
		table2016 = page %>% html_nodes(".mlb-player-basicstatsbox > table") %>% nth(3) %>% html_table()
		tmp = data.frame(player,club,age,position,table2016)
		data = rbind(data,tmp)
	}
	print(player)
}



