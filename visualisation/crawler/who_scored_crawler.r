    # who_scored_crawler

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

download_data <- function(csv,path){
    # csv : a csv file with at least a column named "URL" with whoScored match url
    # path : path to save data (json files)
    data_url <- read_csv(csv) %>% na.omit() %>% select(URL)
    for(url in data_url$URL){
        get_data(url,path=path)
        Sys.sleep(5)
    }
}

