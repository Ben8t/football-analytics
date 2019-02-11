# pass_angle.r
library(dplyr)
library(rvest)
library(hrbrthemes)
library(jsonlite)
library(igraph)
library(ggnetwork)
library(magick)
library(viridis)
library(ggforce)
library(gtable)
library(gridExtra)
library(grid)

source("src/core.r")
source("utils/utils.r")

g_legend <- function(a.gplot){ 
  tmp <- ggplot_gtable(ggplot_build(a.gplot)) 
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box") 
  legend <- tmp$grobs[[leg]] 
  return(legend)}

pass_angles <- function(cleaned_data, lineup) {
    player_passes <- get_players_passes(cleaned_data)
    pass_angles_plots = list()
    for (i in c(1:length(lineup$playerName))){
        pass_angles_plots[[i]] = list()
        data_plot <- player_passes %>% 
            filter(from==lineup$playerName[[i]]) %>%
            group_by(angle) %>% 
            summarise(mean_distance=mean(distance), n=n()) %>% 
            mutate(freq=n / sum(n)) %>% 
            data.frame(.)
        playerName <- lineup$playerName[[i]]
        playerId <- lineup$playerId[[i]]
        pass_angles_plots[[i]]$id <- lineup$playerId[[i]]
        pass_angles_plots[[i]]$name <- lineup$playerName[[i]]
        plot <- ggplot(data_plot) +
            geom_bar(stat="identity", aes(x=angle, y=freq, fill=mean_distance)) + 
            coord_polar(start=pi, direction=1) +
            scale_x_continuous(limits=c(-180,180),breaks=seq(-180, 180, 45)) + 
            scale_fill_gradientn(colours=c("#83FFC3","#56FFAE","#00CB69","#00793F")) + 
            theme(legend.title=element_text(size=20, color="#FEFEFE"),legend.text = element_text(colour="#FEFEFE", size=20),legend.position="bottom",legend.direction="horizontal",legend.background=element_rect(fill=alpha('#FEFEFE', 0.0))) +
            guides(fill=guide_colorbar(
                title="Average Pass Distance",
                title.position="top", 
                title.hjust=0,
                barheight = 3,
                barwidth = 15))
        pass_angles_plots[[i]]$plot <- annotation_custom(
            grob=ggplotGrob(plot + 
                theme_minimal() + 
                theme_ipsum_rc() + 
                theme(axis.title=element_blank(),
                axis.text=element_blank(),
                axis.ticks=element_blank(),
                legend.position="none",
                panel.background=element_blank(),
                panel.grid.minor=element_blank(),
                panel.grid.major = element_blank())
            ), 
            xmin=-(lineup$horizontal[[i]] - 1.8),
            xmax=-(lineup$horizontal[[i]] + 1.8),
            ymin=lineup$vertical[[i]] - 1.8, 
            ymax=lineup$vertical[[i]] + 1.8
        )
    }
    legend <- g_legend(plot) 
    results = list()
    results[[1]] = pass_angles_plots
    results[[2]] = legend
    return(results)
}

passsonar <- function(cleaned_data, lineup){
  pass_angles_graphic <- pass_angles(cleaned_data, lineup)
  base <- ggplot(lineup) + 
    geom_rect(aes(xmin = -10, xmax = 0, ymin = 0, ymax = 12), #entire pitch with FIFA dimensions
        fill = "#1b4d99", 
        colour = "#80A0C6", 
        size = .5) +
    geom_circle(aes(x0 = -5, y0 = 6, r = 1), colour="#80A0C6") + #centre circle
    geom_circle(aes(x0 = -5, y0 = 1.7, r = 0.7), colour="#80A0C6") + #penalty arc
    geom_circle(aes(x0 = -5, y0 = 10.3, r = 0.7), colour="#80A0C6") + #penalty arc
    geom_rect(aes(xmin = -7, xmax = -3, ymin = 0, ymax = 2), #penalty box
              fill = "#1b4d99", 
              colour = "#A9C4DF", 
              size = .5) +
    geom_rect(aes(xmin = -7, xmax = -3, ymin = 10, ymax = 12),  #penalty box
              fill = "#1b4d99", 
              colour = "#80A0C6", 
              size = .5) +
    geom_point(aes(x = -5, y = 1.5), colour="#80A0C6") + #penalty spot
    geom_point(aes(x = -5, y = 10.5), colour="#80A0C6") + #penalty spot
    geom_rect(aes(xmin = -6, xmax = -4, ymin = 0, ymax = 1), #6 yard box
              fill = "#1b4d99", 
              colour = "#80A0C6", 
              size = .5) +
    geom_rect(aes(xmin = -6, xmax = -4, ymin = 11, ymax = 12),  #6 yard box
              fill = "#1b4d99", 
              colour = "#80A0C6", 
              size = .5) +
    geom_segment(aes(x = -10, y = 6, xend = 0, yend = 6), colour="#80A0C6") + #halfway line
    coord_fixed() +
    theme(rect = element_blank(), #remove additional ggplot2 features: lines, axis, etc...
          line = element_blank(),axis.title.y = element_blank(),
          legend.position="none",
          axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.text.y = element_blank()) +
    geom_text(aes(x=-horizontal, y=vertical, label=playerName), hjust=0.5, vjust=-6, size=8, color="#FEFEFE")

  final_plot <- base + 
      pass_angles_graphic[[1]][[1]]$plot + 
      pass_angles_graphic[[1]][[2]]$plot +
      pass_angles_graphic[[1]][[3]]$plot + 
      pass_angles_graphic[[1]][[4]]$plot +
      pass_angles_graphic[[1]][[5]]$plot + 
      pass_angles_graphic[[1]][[6]]$plot +
      pass_angles_graphic[[1]][[7]]$plot +
      pass_angles_graphic[[1]][[8]]$plot + 
      pass_angles_graphic[[1]][[9]]$plot +
      pass_angles_graphic[[1]][[10]]$plot + 
      pass_angles_graphic[[1]][[11]]$plot +
      theme_ipsum_rc() + 
      theme(axis.title=element_blank(),
                    axis.text=element_blank(),
                    axis.ticks=element_blank(),
                    panel.background=element_blank(),
                    legend.position="none",
                    plot.background = element_rect(fill = "#1b4d99"),
                    panel.grid.major = element_blank(),
                    panel.grid.minor = element_blank()) +
      annotation_custom(grob=pass_angles_graphic[[2]], xmin=-9.5, ymin=0.3, xmax=-7.5, ymax=1) +
      xlim(-10.5, 0.5) + 
      ylim(0, 12)
  return(final_plot)
}

create_graphic <- function(passsonar, folder, team, team_name, team_scoreboard, datetime, league_name){
  ggsave(filename=paste0(folder, "g_passsonar_tmp.png"), passsonar, width=15, height=18, dpi=150, bg = "#1b4d99")
  background <- image_read("./template/passsonar/background_passsonar.png")
  foreground <- image_read("./template/passsonar/foreground_passsonar.png")
  title <- image_read("./template/passsonar/title_passsonar.png")
  passsonar <- image_read(paste0(folder, "g_passsonar_tmp.png"))
  logo <- image_read(paste0(folder, team, "_logo.png"))
  full_image <- background %>% 
    image_composite(passsonar, offset="+0+150") %>% 
    image_composite(foreground) %>% 
    image_composite(image_scale(logo,"220"), offset = "+250+200") %>% 
    image_composite(title) %>%
    image_annotate(team_scoreboard, font="Roboto", size=75, location="+500+220", color="white") %>% 
    image_annotate(paste0(league_name, " - ", datetime), font="Roboto", size=45, location="+500+320", color="grey") %>% 
    image_annotate("Bar length = pass angle frequency\n                                              @Ben8t", font="Roboto", size=35, location="+1465+2560", color="white")
  
  file_name <- paste0("passsonar_", gsub(" ", "", team_name, fixed=TRUE), "_", gsub("/", "", datetime, fixed=TRUE), ".png")
  image_write(full_image, path=paste0(folder, file_name), format="png")
}


pdf(NULL)
args <- commandArgs(trailingOnly=TRUE)
folder <- args[[1]]
template_settings <- template_selector(folder)
data <- jsonlite::fromJSON(paste0(folder, "data.json"))
cleaned_data <- event_cleaning(data)
datetime <- get_game_datetime(data)

for(team in c("home", "away")) {
    lineup <- get_lineup(data, team) %>% left_join(., get_playersId_playersNames(data), by="playerId")
    team_name <- get_team_name(data, team)
    team_scoreboard <- get_game_information_text(data, team)
    map <- passsonar(cleaned_data, lineup)
    create_graphic(map, folder, team, team_name, team_scoreboard, datetime, template_settings$league_name)
}
