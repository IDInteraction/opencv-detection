# Explore using binomial regression instead of a recursive partitioning tree
# Using the full-face data with object tracking

library(rpart)
library(REEMtree)
library(formula.tools)
library(IDInteraction)
library(party)
library(sqldf)
rm(list=ls())


participants <- getParticipantCodes("/mnt/IDInteraction/dual_screen_free_experiment/tracking/high_quality/front_full_face/")
trainingtimes <- c(1,2,5,10)
table1formula <- attentionName ~ boxHeight +  boxRotation + boxArea + boxWidth + widthHeightRatio + boxYcoordRel
binomialRegressionFormula <- attentionIpad ~ boxHeight +   boxRotation +  boxWidth + widthHeightRatio + boxYcoordRel 

allparticipants <- loadExperimentData(participants,
                                      trackingLoc = "/mnt/IDInteraction/dual_screen_free_experiment/tracking/high_quality/front_full_face/",
                                      annoteLoc = "/mnt/IDInteraction/dual_screen_free_experiment/attention/")




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
    fitGlm <- glm(binomialRegressionFormula,
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
 

 
tableBinomial <- sqldf("select trainingtime, avg(accuracy) as avgaccuracy
                       from allresults
                       group by trainingtime")

  
  
save(tableBinomial, 
     binomialRegressionFormula,
     trainingtimes,
     file="binomialregression.RData")  

  
