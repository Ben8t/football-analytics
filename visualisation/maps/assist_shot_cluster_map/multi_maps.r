
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

# Colors
background_color = "#2162AA"
foreground_color = "#F7F6F4"
line_color = c("#00A6FF", "#00C3FF", "#00DAE5", "#00EBB8", "#9DF68A", "#F9F871")
text_color = "white"
cluster_number = 5

# Load data
data <- read_csv("/data/cluster.csv", 
        col_types = cols(x_pass_end = col_double(), x_shot = col_double(), 
        y_pass_end = col_double(), y_shot = col_double()
    )
)
data <- data %>% filter(x_shot>105/2) %>% filter(x_pass_begin>105/2) 
set.seed(42)


compute_cluster <- function(data, cluster_number){
	final_data <- data.frame()
	teams <- data %>% distinct(team_name)
	for(team in teams$team_name){
		print(team)
		team_data <- data %>% filter(team_name==team)
		kmeans_result = kmeans(team_data %>% 
		   select(x_pass_begin, 
			  y_pass_begin, 
			  x_pass_end, 
			  y_pass_end, 
			  x_shot, 
			  y_shot) %>% 
		   na.omit(), cluster_number, iter.max = 50)
		cluster_centroid = kmeans_result$centers %>% as.data.frame() %>% mutate(size=kmeans_result$size,cluster_name=LETTERS[1:cluster_number], team_name=team)
		final_data <- rbind(final_data, cluster_centroid)
	}
	final_data
}

cluster_centroid <- compute_cluster(data, cluster_number)

plot <- ggplot(data=cluster_centroid) +  geom_rect(aes(xmin = 0, xmax = 68, ymin = 0, ymax = 105), #entire pitch with FIFA dimensions
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
geom_segment(data=cluster_centroid, 
aes(x=-y_pass_begin+68, y=x_pass_begin, xend=-y_pass_end+68, yend=x_pass_end, color=size),
size=1.25) +
scale_color_gradientn(colours=line_color) +
geom_segment(data=cluster_centroid, 
aes(x=-y_pass_end+68, y=x_pass_end, xend=-y_shot+68, yend=x_shot, color=size),
size=1.25,
lineend='butt',
linejoin='mitre',
arrow = arrow(length = unit(0.25, "cm"),type="closed")) +
geom_point(data=cluster_centroid,
aes(x=-y_pass_begin+68, y=x_pass_begin, color=size),
size=2) +
geom_text(data=cluster_centroid, aes(x=-y_pass_begin+68, y=x_pass_begin, label=cluster_name),
hjust=-1.2, 
vjust=1.2, 
colour=foreground_color) +
geom_point(data=cluster_centroid,
aes(x=-y_pass_end+68, y=x_pass_end, color=size),
size=2) +
coord_cartesian(ylim=c(55, 105))

g <- plot + facet_wrap(. ~ team_name, ncol=5) + theme(strip.text.x = element_text(size=30, color="white"), panel.background = element_rect(fill = "transparent")) 
ggsave("test.png", g, width=40, height=25, bg="transparent")
