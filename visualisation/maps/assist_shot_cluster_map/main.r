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

source(file="src/assist_shot_cluster_map.r")

# Launcher 
data_file = "data/arsenal_assists_shots_against_20172018.csv"
text = "Arsenal assists-shots conceded in 2017-2018 Premier League season."
final_filename = "img/arsenal1718_assists_shots_cluster_map.png"

# Colors
background_color = "#2162AA"
foreground_color = "#F7F6F4"
line_color = c("#00A6FF", "#00C3FF", "#00DAE5", "#00EBB8", "#9DF68A", "#F9F871")
text_color = "white"
cluster_number = 6

# Load data
data <- read_csv(data_file, 
    col_types = cols(event_id = col_character(), 
        next_event_id = col_character(), 
        x_pass_end = col_double(), x_shot = col_double(), 
        y_pass_end = col_double(), y_shot = col_double()
    )
)

# Build graphic
map <- assist_shot_cluster_map(data, background_color, foreground_color, line_color, cluster_number)
create_graphic(map, text, final_filename, background_color, text_color)