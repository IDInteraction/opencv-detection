library(shiny)


function(input, output){
  
  output$plot <- renderPlot({
    
    thisparticipant <- comparepredictions[comparepredictions$participantCode == input$participant &
                                          comparepredictions$traintime == input$traintime,]
    
    numframes <- nrow(thisparticipant)
    minrow <- input$frames[1]/100 * numframes
    maxrow <- input$frames[2]/100 * numframes
    
    croppedparticipant <- thisparticipant[minrow:maxrow,]
    
    pptPreds <- getPredictions(croppedparticipant)
    
    ggp <-   ggplot(pptPreds, aes(obs, pred, z= prop)) + 
      geom_tile(aes(fill = prop)) + theme_bw() + facet_wrap(~method) +
      scale_fill_gradient(low="white", high="black") 
    
    plot(ggp)
  
    
  })
  
}