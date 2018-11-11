library(ggplot2)
library(ggforce)

background_color = "#2162AA"
foreground_color = "#F7F6F4"

ggplot() +  geom_rect(aes(xmin = 0, xmax = 105, ymin = 0, ymax = 68), #entire pitch with FIFA dimensions
            fill = background_color, 
            colour = foreground_color, 
            size = .5) +
            geom_circle(aes(x0 = 105 / 2, y0 = 68 / 2, r = 9.15), colour=foreground_color) + #centre circle
            geom_circle(aes(x0 = 11, y0 = 68 / 2, r = 9.15), colour=foreground_color) + #penalty arc
            geom_circle(aes(x0 = 105 - 11, y0 = 68 / 2, r = 9.15), colour=foreground_color) + #penalty arc
            geom_rect(aes(xmin = 0, xmax = 16.5, ymin = 68 / 2 - 7.32 / 2 - 16.5, ymax = 68 / 2 + 7.32 / 2 + 16.5), #penalty box
                      fill = background_color, 
                      colour = foreground_color, 
                      size = .5) +
            geom_rect(aes(xmin = 105 - 16.5, xmax = 105, ymin = 68 / 2 - 7.32 / 2 - 16.5, ymax = 68 / 2 + 7.32 / 2 + 16.5),  #penalty box
                      fill = background_color, 
                      colour = foreground_color, 
                      size = .5) +
            geom_point(aes(x = 11, y = 68 / 2), colour=foreground_color) + #penalty spot
            geom_point(aes(x = 105 -11, y = 68 / 2), colour=foreground_color) + #penalty spot
            geom_segment(aes(x = -.5, xend = -.5, y = 68 / 2 + 7.32 / 2, yend = 68 / 2 - 7.32 / 2), colour=foreground_color) + #goal
            geom_segment(aes(x = 105.5, xend = 105.5, y = 68 / 2 + 7.32 / 2, yend = 68 / 2 - 7.32 / 2), colour=foreground_color) + #goal
            geom_rect(aes(xmin = 0, xmax = 5.5, ymin = 68 / 2 - 7.32 / 2 - 5.5, ymax = 68 / 2 + 7.32 / 2 + 5.5), #6 yard box
                      fill = background_color, 
                      colour = foreground_color, 
                      size = .5) +
            geom_rect(aes(xmin = 105 - 5.5, xmax = 105, ymin = 68 / 2 - 7.32 / 2 - 5.5, ymax = 68 / 2 + 7.32 / 2 + 5.5),  #6 yard box
                      fill = background_color, 
                      colour = foreground_color, 
                      size = .5) +
            geom_segment(aes(x = 105 /2, y = 0, xend = 105 / 2, yend = 68), colour=foreground_color) + #halfway line
            coord_fixed() +
              theme(rect = element_blank(), #remove additional ggplot2 features: lines, axis, etc...
                  line = element_blank(),axis.title.y = element_blank(),
                  legend.position = "none", 
                  axis.title.x = element_blank(),
                  axis.text.x = element_blank(),
                  axis.text.y = element_blank())
