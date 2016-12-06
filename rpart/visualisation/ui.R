library(shiny)
setwd("/home/zzalsdme/opencv/abc-classifier/rpart/visualisation")
source("loaddata.R")

participants <- unique(comparepredictions$participantCode)

participantlist <-as.list(as.character(participants))
names(participantlist) <- as.character(participants)

trainingTimes <- unique(comparepredictions$traintime)
trainingTimesList <- as.list(trainingTimes)
names(trainingTimesList) <- as.character(trainingTimes)

fluidPage(
  
  titlePanel("Prediction comparison"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("participant", label=h3("Select participant"),
                  choices = participantlist),
      
      br(),
      
      selectInput("traintime", label=h3("Select training time"),
                  choices = trainingTimesList),
      
      br(),
      
      sliderInput("frames", label=h3("Select proportion"),
                  min = 1, max= 100, value=c(0,100))
    ),
    
    mainPanel(
      plotOutput("plot")
    )
    
  )
)