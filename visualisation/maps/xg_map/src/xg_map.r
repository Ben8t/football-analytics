# xg_map.r

xg_map <- function(data, background_color, foreground_color, color1, color2, color3){
    # Build the main map
    data$xG_cut <- cut(data$xG, breaks=c(0,0.5,1), right = FALSE)
    data <- data %>% mutate(xG_cut=ifelse(is_goal==1, "goal", xG_cut))
    if(length(table(data$xG_cut)) == 3){
        colors_value = c(color1, color2, color3)
    }else{
        colors_value = c(color1, color3)
    }
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
            geom_point(data=data, aes(x=-y_shot + 68, y=x_shot, size=xG, color=xG_cut, shape=factor(is_goal))) +
            scale_shape_manual(values=c(16, 16)) +
            scale_color_manual(values=colors_value) + 
            coord_cartesian(ylim=c(55, 105)) 
}

get_stats <- function(data){
    # Gather shots statisics from data
    shots <- nrow(data)
    goals <- sum(data$is_goal)
    total_xg <- round(sum(data$xG), 2)
    xg_by_shot <- round(total_xg/shots, 2)
    paste0("Total xG = ", total_xg, "\nGoals = ", goals, "\nShots = ", shots, "\nxG per shot = ", xg_by_shot)
}

create_graphic <- function(xg_map, text, stats, filepath, background_color, text_color){
    # Create full graphic with map, title and text
    ggsave(filename="img/g_xgmap_tmp.png", xg_map + theme(plot.margin=unit(c(3.5,0,-0.3,0),"cm")), width=10.5, height=8, dpi=150, bg=background_color)
    xg_map <- image_read("img/g_xgmap_tmp.png")
    title <- image_read("template/title.png")
    foreground <- image_read("template/foreground.png")
    full_image <- xg_map %>%
        image_composite(image_scale(title,"600"), offset="+70-40") %>%
        image_composite(foreground) %>%
        image_annotate(text, font="Roboto", size=35, location="+80+190", color=text_color) %>%
        image_annotate(stats, font="Roboto", size=25, location="+120+725", color=text_color)
    image_write(full_image, path=filepath)
}