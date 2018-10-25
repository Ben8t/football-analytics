# crawler.r

library(tidyverse)
library(rvest)
library(jsonlite)

get_name_from_url <- function(url){
    m <- regexpr("(?<=Live\\/).*$",url,perl=TRUE)
    res <- regmatches(url,m)
    name <- paste0(res,".json")
    return(name)
}

get_data <- function(url,path="data/divers/"){
    filename = get_name_from_url(url)
    print(filename)
    json = url %>% read_html() %>% html_nodes(xpath='//*[@id="layout-content-wrapper"]/script[1]/text()') %>% html_text() %>% nth(1)
    m <- regexpr("\\{.*\\}", json, perl=TRUE)
    res <- regmatches(json, m)
    write(res,paste0(path,filename))
}

# url = "https://www.whoscored.com/Matches/1190346/Live/England-Premier-League-2017-2018-Crystal-Palace-Burnley"
# get_name_from_url(url)
# get_data(url)
