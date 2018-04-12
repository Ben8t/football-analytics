# app.r
# https://cran.r-project.org/web/packages/magick/vignettes/intro.html#combining_with_pipes

library(tidyverse)
library(hrbrthemes)
library(ggforce)
library(jsonlite)
library(grid)
library(gridExtra)
library(igraph)
library(ggnetwork)
library(magick)

background = image_read("background.png")
passnetwork = image_read("../img/g_passnetwork_tmp.png")
logo = image_read('basic-logo.png')

full_image <- image_composite(background, image_scale(passnetwork,"3600"), offset = "+200+480") %>%
              image_composite(., image_scale(logo,"450"), offset="+80+40") %>%
              image_annotate(.,"Passnetwork", font = 'Roboto Condensed', size = 180, location="+585+0", color="#373737") %>%
              image_annotate(.,"Team A against team B - 2:0", font = 'Roboto Condensed', size = 130, location="+620+200", color="white") %>%
              image_annotate(.,"Premier League - 01/01/2018", font = 'Roboto Condensed', size = 70, location="+630+350", color="white") %>%
              image_annotate(.,"Lines for 5 passes or more \nData from WhoScored/Opta", font = 'Roboto Condensed', size = 50, location="+50+2300", color="#373737") %>%
              image_annotate(.,"by Benoit Pimpaud / @Ben8t", font = 'Roboto Condensed', size = 70, location="+50+2420", color="#373737")
