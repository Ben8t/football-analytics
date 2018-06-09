## ui.R ##

library(colourpicker)

ui <- bootstrapPage(htmlTemplate("template.html",
  url = textInput("url", label="", value="https://www.whoscored.com/Matches/1225382/Live/Italy-Serie-A-2017-2018-Inter-Benevento"),
  logo = fileInput("logo_file", label = ""),
  radio = radioButtons("radio", label = "",
                    choices = list("Home" = "home", "Away" = "away"),
                    selected = "home"),
  league = textInput("league", label = "", value = "2018 World Cup"),
  color = colourInput("color", label="", "red"),
  go = actionButton("action", label = "Go"),
  download = downloadButton('downloadData'),
  image = imageOutput("preImage", width = "10%")
))
