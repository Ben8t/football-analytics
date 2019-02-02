# Build XG Map with R
library(dplyr)
library(rvest)
library(hrbrthemes)
library(magick)
library(viridis)
library(ggforce)
library(gtable)
library(gridExtra)
library(grid)
library(readr)

source(file="src/xg_map.r")  # import xg map functions

# Launcher 
data_file <- "data/wolve_xg_1819.csv"
text <- "Wolverhampton shots from 2018-2019 Premier League season."
final_filename <- "img/wolves_xgmap_1819.png"

# Colors
background_color <- "#2162AA"
foreground_color <- "#F7F6F4"
color1 <- "#64BEF3"
color2 <- "#FFCB41"
color3 <- "#56FFAE"
text_color <- "white"

# Load data
data <-  read_csv(data_file)

# Filter data
# you can filter on team_name or player_name
# data <- data %>% filter(startDate > "2018-08-01")

# Build graphic
stats <- get_stats(data)  # gather stats
map <- xg_map(data, background_color, foreground_color, color1, color2, color3)  # build map
create_graphic(map, text, stats, final_filename, background_color, text_color)  # build full graphic
