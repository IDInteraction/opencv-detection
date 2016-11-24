

# Remove elsewheres so we have binary outcome
allparticipantsNoElsewhere <- allparticipants[-which(allparticipants$attentionName == "elsewhere") , ]
allparticipantsNoElsewhere$attentionName <- factor(allparticipantsNoElsewhere$attentionName)

allpreds <- NULL
allresults <- NULL
for(p in participants){
  print(p)
  
  
  
  participantdata <- allparticipantsNoElsewhere[allparticipantsNoElsewhere$participantCode == p ,]
  
  for(tt in trainingtimes){
    
    #http://www.statmethods.net/advstats/glm.html
    fitGlm <- glm(attentionIpad ~ ffboxHeight +   ffboxRotation +  
                    ffboxWidth + ffwidthHeightRatio + ffboxYcoordRel ,
                  data=participantdata,
                  family=binomial,
                  subset = flagtraining(participantdata, tt)
    )
    
    predictiondata <- participantdata[!flagtraining(participantdata,tt), ]
    
    glmpreds <- data.frame(participantCode = p,
                           timestampms = predictiondata$timestampms,
                           predprob = predict(fitGlm, 
                                              newdata = predictiondata,
                                              type="response"))
    
    predictiondata$prediction <- factor(ifelse(glmpreds$predprob < 0.5, "tv", "ipad"),
                                  levels = levels(allparticipantsNoElsewhere$attentionName))
    
    accuracy <- getAccuracy(with(predictiondata, table(attentionName, prediction)))
    allresults <- rbind(allresults, 
                        data.frame(participant = p,
                                   trainingtime = tt,
                                   accuracy = accuracy)
    )
    
    
    allpreds <- rbind(allpreds, glmpreds)
    
  }
}
 

 
tableBiniomial <- sqldf("select trainingtime, avg(accuracy) as avgaccuracy
                       from allresults
                       group by trainingtime")

  
  
  

  