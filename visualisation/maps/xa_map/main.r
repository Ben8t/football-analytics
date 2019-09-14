# xA map

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

source(file="src/xa_map.r")

# Launcher 
data_file <- "data/bernardo_silva_xa.csv"
text <- "Bernardo Silva passes from 2018-2019 Premier League season"
final_filename <- "bernardo_silva_xa_map_1819.png"

# Colors
background_color <- "#2162AA"
foreground_color <- "#F7F6F4"
text_color <- "white"
color1 <- "#64BEF3"
color2 <- "#FFCB41"
color3 <- "#56FFAE"
high_gradient_color <- "#64BEF3"

# Load data
data <-  read_csv(data_file)

# Filter data
# you can filter on team_name or player_name
# data <- data %>% filter(player_name=="Olivier Giroud")

# Build map
stats <- get_stats(data)
map <- xa_map(data, background_color, foreground_color, color1, color2, color3, high_gradient_color)
create_graphic(map, text, stats, final_filename, background_color, text_color)