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

background_color = "#2162AA"
foreground_color = "#F7F6F4"

xa_map <- function(data, background_color, foreground_color, c1, c2, c3){
      data <- data %>% filter(xA >= 0 | is_assist == 1)
      data$xA_cut = cut(data$xA, breaks=c(0,0.1,1), right = FALSE)
      data = data %>% mutate(xA_cut = ifelse(is_assist==1, "assist", xA_cut))
      if(length(table(data$xA_cut)) == 3){
            colors_value = c(c1, c2, c3)
      }else{
            colors_value = c(c1, c3)
      }
      print(colors_value)
      ggplot() +  geom_rect(aes(xmin = 0, xmax = 68, ymin = 0, ymax = 105), #entire pitch with FIFA dimensions
                        fill = background_color, 
                        colour = foreground_color, 
                        size = .5) +
      geom_circle(aes(x0 = 68 / 2, y0 = 105 / 2, r = 9.15), colour=foreground_color) + #centre circle
      geom_circle(aes(x0 = 68 / 2, y0 = 11, r = 9.15), colour=foreground_color) + #penalty arc
      geom_circle(aes(x0 = 68 / 2, y0 = 105 - 11, r = 9.15), colour=foreground_color) + #penalty arc
      geom_rect(aes(xmin = 68 / 2 - 7.32 / 2 - 16.5, xmax = 68 / 2 + 7.32 / 2 + 16.5, ymin = 0, ymax = 16.5), #penalty box
                  fill = background_color, 
                  colour = foreground_color, 
                  size = .5) +
      geom_rect(aes(xmin = 68 / 2 - 7.32 / 2 - 16.5, xmax = 68 / 2 + 7.32 / 2 + 16.5, ymin = 105, ymax = 105 - 16.5), #penalty box
                  fill = background_color, 
                  colour = foreground_color, 
                  size = .5) +
      geom_point(aes(x = 68 / 2, y = 11), colour=foreground_color) + #penalty spot
      geom_point(aes(x = 68 / 2, y = 105 -11), colour=foreground_color) + #penalty spot
      geom_rect(aes(xmin = 68 / 2 - 7.32 / 2 - 5.5, xmax = 68 / 2 + 7.32 / 2 + 5.5, ymin = 0, ymax = 5.5), #6 yard box
                  fill = background_color, 
                  colour = foreground_color, 
                  size = .5) +
      geom_rect(aes(xmin = 68 / 2 - 7.32 / 2 - 5.5, xmax = 68 / 2 + 7.32 / 2 + 5.5, ymin = 105, ymax = 105 - 5.5), #6 yard box
                  fill = background_color, 
                  colour = foreground_color, 
                  size = .5) +
      geom_segment(aes(x = 0, y = 105/2, xend = 68, yend = 105/2), colour=foreground_color) + #halfway line
      coord_fixed() +
      theme(rect = element_blank(), #remove additional ggplot2 features: lines, axis, etc...
            line = element_blank(),axis.title.y = element_blank(), 
            legend.position = "None",
            axis.title.x = element_blank(),
            axis.text.x = element_blank(),
            axis.text.y = element_blank()) +
      stat_density2d(data=data, aes(x=-y_end+68,y=x_end,fill=..level..), alpha=0.3,geom="polygon", show.legend=FALSE) +
      scale_fill_gradient(low = background_color, high = "#64BEF3") + 
      geom_point(data=data, aes(x=-y_begin + 68, y=x_begin, color=xA_cut, size=xA)) + 
      scale_color_manual(values=colors_value) + 
      coord_cartesian(ylim=c(55, 105))
}

get_stats <- function(data){
    passes <- nrow(data)
    assist <- sum(data$is_assist)
    total_xa <- round(sum(data$xA), 2)
    paste0("Total xA = ", total_xa, "\nAssists = ", assist, "\nPasses = ", passes)
}

create_graphic <- function(xa_map, text, stats, filepath){
    ggsave(filename="img/g_xamap_tmp.png", xa_map + theme(plot.margin=unit(c(3.5,0,-0.3,0),"cm")), width=10.5, height=8, dpi=150, bg="#2162AA")
    xg_map <- image_read("img/g_xamap_tmp.png")
    title <- image_read("template/xa_map/title.png")
    foreground <- image_read("template/xa_map/foreground.png")
    full_image <- xg_map %>%
        image_composite(image_scale(title,"600"), offset="+70-40") %>%
        image_composite(foreground) %>%
        image_annotate(text, font="Roboto", size=35, location="+80+190", color="white") %>%
        image_annotate(stats, font="Roboto", size=25, location="+120+725", color="white")
    image_write(full_image, path=filepath)
}

# Launcher 
data_file = "/Users/ben/Downloads/ozil_xa.csv"
text = "Mezut Ozil passes from 2017-2018 Premier League seasons"
final_filename = "/Users/ben/Downloads/tmp_xamap.png"

# load data
data <-  read_csv(data_file)
# filter data
# you can filter on team_name or player_name
# data <- data %>% filter(player_name=="Olivier Giroud")

stats <- get_stats(data)
# build xG map
map <- xa_map(data, "#2162AA", "#F7F6F4","#64BEF3", "#FFCB41", "#56FFAE")

# build full graphic
create_graphic(map, text, stats, final_filename)