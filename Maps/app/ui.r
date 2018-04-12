# ui.r #

library(shinythemes)
library(colourpicker)

ui <- fluidPage(theme = shinytheme("united"),
        navbarPage("Passnetwork builder",
          tabPanel("Plot",
              mainPanel(
                textInput("url", label = h3("URL"), value = "https://www.whoscored.com/Matches/1225382/Live/Italy-Serie-A-2017-2018-Inter-Benevento"),
                fileInput("logo_file", label = h3("Logo")),
                radioButtons("radio", label = h3("Team"),
                    choices = list("Home" = "home", "Away" = "away"), 
                    selected = "home"),
                fluidRow(column(2, verbatimTextOutput("value"))),
                actionButton("action", label = "GO"),
                colourInput("color", "Select colour", "purple"),
                imageOutput("preImage",width = "10%")
              )
            )
          )
        )
