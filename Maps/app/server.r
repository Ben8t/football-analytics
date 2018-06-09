# server.r #
# install.packages
library(dplyr)
library(rvest)
library(hrbrthemes)
library(jsonlite)
library(igraph)
library(ggnetwork)
library(magick)

get_name_from_url <- function(url){
    m <- regexpr("(?<=Live\\/).*$",url,perl=TRUE)
    res <- regmatches(url,m)
    name <- paste0(res,".json")
    return(name)
}

get_data <- function(url){
    print("DOWNLOAD DATA...")
    filename = get_name_from_url(url)
    print(url)
    json = url %>% read_html() %>% html_nodes(xpath='//*[@id="layout-content-wrapper"]/script[1]/text()') %>% html_text() %>% nth(1)
    m <- regexpr("\\{.*\\}", json, perl=TRUE)
    res <- regmatches(json, m)
    return(res)
}

get_lineup_and_final_text <- function(data,TEAM){
    # Return TEAM lineup and create final text for design purposes (title)
    home_team = data$home$name
    away_team = data$away$name
    score_home = unlist(strsplit(data$score, "\\s+"))[1]
    score_away = unlist(strsplit(data$score, "\\s+"))[3]
    if(TEAM=="home"){
        lineup = data$home$formations$playerIds[[1]] %>% as.data.frame() %>% select(.,playerId=.) %>% slice(1:11)
        final_text = paste0(home_team," against ",away_team," - ",score_home,":",score_away)
    }else if(TEAM=="away"){
        lineup = data$away$formations$playerIds[[1]] %>% as.data.frame() %>% select(.,playerId=.) %>% slice(1:11)
        final_text = paste0(away_team," away at ",home_team," - ",score_home,":",score_away)
    }

    # time part
    datetime = data$timeStamp %>% substr(., 1,10)
    day = substr(datetime,9,10)
    month = substr(datetime,6,7)
    year = substr(datetime,1,4)
    clean_datetime = paste0(day,"/",month,"/",year)

    return(c(lineup,final_text,clean_datetime))
}

get_players_passes <- function(lineup_event){
    player_passes=data.frame()
    for(i in c(1:(nrow(lineup_event)-2))){
        if(lineup_event$typeValue[i]==1 & lineup_event$typeValue[i+1]==1){
            player_passes = rbind(player_passes,data.frame(from=lineup_event$playerName[i],to=lineup_event$playerName[i+1]))
        }
    }
    return(player_passes)
}

passnetwork <-function(TEAM="home", TEAM_COLOR="black", PASS_NUMBERS=5, URL){
        print('RUNNING...')
        data = jsonlite::fromJSON(get_data(URL))
        event = data.frame(id=data$events$id,eventId=data$events$eventId,minute=data$events$minute,second=data$events$second,teamId=data$events$teamId,playerId=data$events$playerId,x=data$events$x,y=data$events$y,typeValue=data$events$type$value,typeDisplayName=data$events$type$displayName,period=data$events$period$value,isTouch=data$events$isTouch,outcome=data$events$outcomeType$value)
        # get player list
        all_players= data$playerIdNameDictionary %>%
            t %>% 
            as.data.frame() %>% 
            t %>% 
            as.data.frame() %>% 
            tibble::rownames_to_column() %>% 
            select(playerName=V1,playerId=rowname) %>% 
            mutate(playerId=as.numeric(playerId),playerName=unlist(playerName))

        event = left_join(event,all_players,by=c("playerId"))  # add player names to event dataframe
        lineup_final_text = get_lineup_and_final_text(data,TEAM)
        lineup = lineup_final_text[1]  # get lineup for either home or away team
        lineup_event = event %>% filter(playerId %in% lineup$playerId)  # filter event accorting to home or away team

        player_passes = get_players_passes(lineup_event)  # get passes for each teammates

        # get ball touch coordinates and touch ball frequency
        touch_coordinates_and_count = event %>% 
            na.omit() %>% 
            filter(isTouch==TRUE) %>%
            filter(playerId %in% lineup$playerId) %>% 
            group_by(playerName) %>% 
            summarise(x_avg=mean(x),y_avg=mean(y),n=n()) %>%
            select(name=playerName,x_avg,y_avg,nb_touch=n) %>%
            as.data.frame()

        # get passes from a teammates to another and frequency
        passes_from_to_count_data <- player_passes %>% 
            group_by(from,to) %>% 
            summarise(n=n()) %>% 
            filter(n>=PASS_NUMBERS)

        igraph_data <- graph.data.frame(passes_from_to_count_data, directed = TRUE, vertices = touch_coordinates_and_count)  # create igraph object
        layout_bound <- layout.norm(as.matrix(touch_coordinates_and_count[,2:3])) # fit coordinates between -1 and 1

        # plot and aesthetics
        ggnetwork_data <- ggnetwork(igraph_data,layout=layout_bound,weights = "n")
        map <- ggplot(ggnetwork_data, aes(x = x, y = y, xend = xend, yend = yend)) +
            geom_edges(aes(color = n),size=1,arrow = arrow(length = unit(9, "pt"), type = "closed"),curvature = 0.05) +
            scale_color_gradientn("Passes",colours = c("#b9f6ca","#69f0ae","#00e676","#1b5e20"))+
            geom_nodes(aes(size=nb_touch),shape = 21, colour = "white", fill = TEAM_COLOR, stroke = 1) +
            scale_size("Touches",range = c(0,15),limits=c(1,max(touch_coordinates_and_count$nb_touch)))+
            geom_nodelabel_repel(aes(label = vertex.names),color=TEAM_COLOR,box.padding = unit(1,"lines")) +
            theme_ipsum_rc()+
            theme(axis.title=element_blank(),axis.text=element_blank(),axis.ticks=element_blank(),panel.grid.major = element_blank(), panel.grid.minor = element_blank(),panel.background = element_blank())

        # save passnetwork in a tmp file
        print("SAVING passnetwork tmp")
        ggsave(filename = "g_passnetwork_tmp_shiny.png", map, width =14, height=8, dpi=300)
        output = list()
        output$team_scoreboard = lineup_final_text[[2]]
        output$datetime = lineup_final_text[[3]]
        print("PASSNETWORK TMP DONE")
        return(output)
}

server <- function(input, output, session) {
    print('SERVER LAUNCHED')
    observeEvent(input$action, {
        withProgress(message = 'Making graphic...', value = 0, {

        # CREATE PASSNETWORK
        incProgress(0.5, detail = "Download and process data...")
        passnetwork_data = passnetwork(URL=input$url,TEAM_COLOR=input$color,TEAM=input$radio)
        print("LOAD BACKGROUND")
        incProgress(0.5, detail = "Loading background")
        background = image_read("./data/background_worldcup.png")
        print("LOAD FOREGROUND")
        incProgress(0.5, detail = "Loading background")
        foreground= image_read("./data/foreground_worldcup.png")
        print("LOAD PASSNETWORK TMP")
        incProgress(0.5, detail = "Loading images...")
        passnetwork = image_read("g_passnetwork_tmp_shiny.png")
        print("LOAD LOGO")
        incProgress(0.5, detail = "Loading image logo...")
        logo = image_read(input$logo_file$datapath)

        full_image <- image_composite(background, image_scale(passnetwork,"3600"), offset = "+200+480") %>%
                      image_composite(foreground) %>%
                      image_composite(., image_scale(logo,"450"), offset="+80+40") %>%
                      image_annotate(.,"Passnetwork", font = 'Roboto Condensed', size = 180, location="+585+40", color="#373737") %>%
                      image_annotate(.,passnetwork_data$team_scoreboard, font = 'Roboto Condensed', size = 130, location="+620+240", color="white") %>%
                      image_annotate(.,paste0(input$league," - ",passnetwork_data$datetime), font = 'Roboto Condensed', size = 70, location="+630+375", color="white") %>%
                      image_annotate(.,"Lines for 5 passes or more \nData from WhoScored/Opta", font = 'Roboto Condensed', size = 50, location="+50+2340", color="#373737") %>%
                      image_annotate(.,"by Benoit Pimpaud / @Ben8t", font = 'Roboto Condensed', size = 70, location="+50+2460", color="#373737")

        print("WRITE FULL IMAGE")
        incProgress(0.5, detail = "Writing full graphic...")
        image_write(full_image, path = "passnetwork.png", format = "png")
        image_write(image_scale(full_image,700), path = "passnetwork_thumbnails.png", format = "png")

        output$downloadData <- downloadHandler(
          filename <- function() {
            "passnetwork.png"
          },

          content <- function(file) {
            file.copy("passnetwork.png", file)
          },
          contentType = "image/png"
        )
        
        

        output$preImage <- renderImage({
            filename <- "passnetwork_thumbnails.png"
         
            # Return a list containing the filename and alt text
            list(src = filename,
                 alt = "Image number")

          }, deleteFile = FALSE)
        incProgress(0.5, detail = "Done")
        print("JOB DONE")
            
        })
    })

}
