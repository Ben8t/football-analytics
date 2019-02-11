
template_selector <- function(folder){
    # Build graphic options like colors, names, etc...
    color = "white"
    line_color = c("#83FFC3","#56FFAE","#00CB69","#00793F")
    if(startsWith(folder, "data/England-Premier-League")){
        league_name = "Premier League"
    } else if(startsWith(folder, "data/Italy-Serie-A")){
        league_name = "Serie A"
    } else if(startsWith(folder, "data/France-Ligue-1")){
        league_name = "Ligue 1"
    } else if(startsWith(folder, "data/Spain-La-Liga")){
        league_name = "La Liga"
    } else if(startsWith(folder, "data/Germany-Bundesliga")){
        league_name = "Bundesliga"
    } else if(startsWith(folder, "data/Europe-UEFA-Champions-League")){
        league_name = "UEFA Champions League"
    } 
    else if(startsWith(folder, "data/England-Championship")){
        league_name = "Championship"
    } 
    else if(startsWith(folder, "data/USA-Major")){
        league_name = "Major League Soccer"
    }
    else if(startsWith(folder, "data/Europe-UEFA-Europa-League")){
        league_name = "UEFA Europa League"
    } else{
        league_name = ""
    }
    output = list()
    output$color = color
    output$league_name = league_name
    output$line_color = line_color
    return(output)
}
