# Passnetwork
library(dplyr)
library(rvest)
library(hrbrthemes)
library(jsonlite)
library(igraph)
library(ggnetwork)
library(magick)

source("src/core.r")
source("src/utils.r")

passnetwork <- function(event_data, lineup, line_color, team_color, pass_number) {
    # Create passnetwork with igraph/ggnetwork
    #
    # Args:
    #   event_data: game events dataframe
    #   lineup: a team lineup to filter data
    #   line_color: color for line (a list)
    #   team_color: color for player position
    #   pass_number: set the minimum pass number to show on map (usually 5)
    # Returns:
    #   ggplot graphic (passnetwork)
    team_event <- event_data %>% filter(playerId %in% lineup$playerId)  # filter event accorting to home or away team
    player_passes <- get_players_passes(team_event)  # get passes for each teammates

    # get ball touch coordinates and touch ball frequency
    touch_coordinates_and_count <- team_event %>%
        filter(isTouch==TRUE) %>%
        group_by(playerName) %>% 
        summarise(x_avg=mean(x), y_avg=mean(y), n=n()) %>%
        select(name=playerName, x_avg, y_avg, nb_touch=n) %>%
        as.data.frame()

    # get passes from a teammates to another and frequency
    passes_from_to_count_data <- player_passes %>% 
        group_by(from, to) %>% 
        summarise(n=n()) %>% 
        filter(n>=pass_number)

    igraph_data <- graph.data.frame(passes_from_to_count_data, directed = TRUE, vertices = touch_coordinates_and_count)  # create igraph object
    layout_bound <- layout.norm(as.matrix(touch_coordinates_and_count[, 2:3])) # fit coordinates between -1 and 1

    # plot and aesthetics
    ggnetwork_data <- ggnetwork(igraph_data, layout=layout_bound, weights="n")
    map <- ggplot(ggnetwork_data, aes(x=x, y=y, xend=xend, yend=yend)) +
        geom_edges(aes(color=n), size=1, arrow=arrow(length=unit(9, "pt"), type="closed"), curvature=0.05) +
        scale_color_gradientn("Passes", colours=line_color) +
        geom_nodes(aes(size=nb_touch), shape=21, colour=team_color, fill=team_color, stroke=1) +
        scale_size("Touches", range=c(0, 15), limits=c(1, max(touch_coordinates_and_count$nb_touch))) +
        geom_nodelabel_repel(aes(label=vertex.names), color="#1b4d99", box.padding=unit(1, "lines")) +
        theme_ipsum_rc() +
        theme(legend.title=element_text(color="white"),legend.text=element_text(color="white"), axis.title=element_blank(), axis.text=element_blank(), axis.ticks=element_blank(), panel.grid.major=element_blank(), panel.grid.minor=element_blank(), plot.background = element_rect(fill = "#1b4d99"))
    return(map)
}

# old version
# create_graphic <- function(passnetwork, folder, team, team_name, team_scoreboard, datetime, team_color, template_name, league_name) {
#         # Create full graphic with passnetwork, images, text, using magick package
#         #
#         # Args:
#         #   passnetwork: a ggplot graphic (built with passnetwork function)
#         #   folder: folder to load and save images
#         #   team: either "home" or "away"
#         #   team_name: team name
#         #   team_scoreboard: game scoreboard (example: "Arsenal against Liverpool - 2:1")
#         #   datetime: game datetime
#         #   team_color: team color
#         #   template_name: graphic template name (to laod corresponding template)
#         #   league_name: league name
#         # Returns:
#         #   Save the full image in the folder as png file
#         ggsave(filename=paste0(folder, "g_passnetwork_tmp.png"), passnetwork, width=14, height=8, dpi=300)
#         background <- image_read(paste0("./template/passnetwork/background_", template_name, ".png"))
#         foreground <- image_read(paste0("./template/passnetwork/foreground_", template_name, ".png"))
#         passnetwork <- image_read(paste0(folder, "g_passnetwork_tmp.png"))
#         logo <- image_read(paste0(folder, team, "_logo.png"))

#         full_image <- image_composite(background, image_scale(passnetwork,"3600"), offset="+200+480") %>%
#                       image_composite(foreground) %>%
#                       image_composite(., image_scale(logo, "400"), offset="+80+80") %>%
#                       image_annotate(., "PassNetwork", font='Roboto Condensed', size=180, location="+585+5", color=team_color) %>%
#                       image_annotate(., team_scoreboard, font='Roboto Condensed', size=130, location="+620+210", color="#1b4d99") %>%
#                       image_annotate(., paste0(league_name, " - ", datetime), font='Roboto Condensed', size=70, location="+630+355", color="#1b4d99") %>%
#                       image_annotate(., "Lines for 5 passes or more", font='Roboto Condensed', size=50, location="+50+2390", color=team_color) %>%
#                       image_annotate(., "by @Ben8t", font='Roboto Condensed', size=70, location="+50+2440", color=team_color)

#         file_name <- paste0("passnetwork_", gsub(" ", "", team_name, fixed=TRUE), "_", gsub("/", "", datetime, fixed=TRUE), ".png")
#         image_write(full_image, path=paste0(folder, file_name), format="png")
#         # image_write(image_scale(full_image,700), path = "passnetwork_thumbnails.png", format = "png")
# }

create_graphic <- function(passnetwork, folder, team, team_name, team_scoreboard, datetime, team_color, league_name) {
        # Create full graphic with passnetwork, images, text, using magick package
        #
        # Args:
        #   passnetwork: a ggplot graphic (built with passnetwork function)
        #   folder: folder to load and save images
        #   team: either "home" or "away"
        #   team_name: team name
        #   team_scoreboard: game scoreboard (example: "Arsenal against Liverpool - 2:1")
        #   datetime: game datetime
        #   team_color: team color
        #   league_name: league name
        # Returns:
        #   Save the full image in the folder as png file
        ggsave(filename=paste0(folder, "g_passnetwork_tmp.png"), passnetwork, width=14, height=8, dpi=300)
        passnetwork <- image_read(paste0(folder, "g_passnetwork_tmp.png"))
        foreground <- image_read("template/passnetwork/foreground_passnetwork.png")
        logo <- image_read(paste0(folder, team, "_logo.png"))

        full_image <- image_scale(passnetwork,"3600") %>%
                      image_composite(foreground) %>%
                      image_composite(., image_scale(logo, "200"), offset="+40+180") %>%
                      image_annotate(., team_scoreboard, font='Roboto Condensed', size=75, location="+260+190", color="white") %>%
                      image_annotate(., paste0(league_name, " - ", datetime), font='Roboto Condensed', size=45, location="+260+280", color="grey") %>%
                      image_annotate(., "Lines for 5 passes or more", font='Roboto Condensed', size=40, location="+40+1930", color="white") %>%
                      image_annotate(., "by @Ben8t", font='Roboto Condensed', size=40, location="+40+1980", color="white")

        file_name <- paste0("passnetwork_", gsub(" ", "", team_name, fixed=TRUE), "_", gsub("/", "", datetime, fixed=TRUE), ".png")
        image_write(full_image, path=paste0(folder, file_name), format="png")
        # image_write(image_scale(full_image,700), path = "passnetwork_thumbnails.png", format = "png")
}

pdf(NULL)
args <- commandArgs(trailingOnly=TRUE)
folder <- args[[1]]
template_settings <- template_selector(folder)
data <- jsonlite::fromJSON(paste0(folder, "data.json"))
cleaned_data <- event_cleaning(data)
datetime <- get_game_datetime(data)

for(team in c("home", "away")) {
    lineup <- get_lineup(data, team)
    team_name <- get_team_name(data, team)
    team_scoreboard <- get_game_information_text(data, team)
    map <- passnetwork(cleaned_data, lineup, template_settings$line_color, "white", 5)
    create_graphic(map, folder, team, team_name, team_scoreboard, datetime, "white", template_settings$league_name)
}
