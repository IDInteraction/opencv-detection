# Predictions using conditional inference trees, using the party package
# See also  http://www.exegetic.biz/blog/2013/05/package-party-conditional-inference-trees/


library(randomForest)
library(rpart)
library(REEMtree)
library(formula.tools)
library(IDInteraction)
library(party)
library(sqldf)
rm(list=ls())


participants <- getParticipantCodes("/mnt/IDInteraction/dual_screen_free_experiment/tracking/high_quality/front_full_face/")
trainingtimes <- c(1,2,5,10)

trainingtime <- trainingtimes

table1formula <- attentionName ~ boxHeight +  boxRotation + boxArea + boxWidth + widthHeightRatio + boxYcoordRel


# allparticipants <- loadExperimentData(participants,
#                                       trackingLoc = "/mnt/IDInteraction/dual_screen_free_experiment/tracking/high_quality/front_full_face/",
#                                       annoteLoc = "/mnt/IDInteraction/dual_screen_free_experiment/attention/")

allresults <- NULL
set.seed(161129)

# participants <- participants[1:2]
# trainingtimes <- trainingtimes[1:2]

for(p in participants){
for(tt in trainingtimes){
  print(paste(p, tt))

  thisparticipant <- loadExperimentData(p,
                                        trackingLoc = "/mnt/IDInteraction/dual_screen_free_experiment/tracking/high_quality/front_full_face/",
                                        annoteLoc = "/mnt/IDInteraction/dual_screen_free_experiment/attention/")


  trainingdata <- thisparticipant[flagtraining(thisparticipant, tt),]
  predictiondata <- thisparticipant[!flagtraining(thisparticipant, tt), ]



  modelFit <-  ctree(table1formula, data = trainingdata)
    

  prediction <- predict(modelFit, predictiondata)

  correct <- prediction == predictiondata$attentionName
  table(prediction, predictiondata$attentionName)
  accuracy <- sum(correct)/nrow(predictiondata)

  thisresult <- data.frame(method = "CITree",
                           participant = p,
                           trainingtime = tt,
                           accuracy = accuracy)

  allresults <- rbind(thisresult, allresults)

}
}


CITreeByTime <- sqldf("select method, trainingtime, avg(accuracy) as accuracy
                       from allresults
                       group by method, trainingtime")
CITreeResults <- allresults


save(table1formula, CITreeByTime,
     CITreeResults, file="conditionalInferenceTrees.RData")

# plot(modelFit)
# varImpPlot(modelFit)
# install.packages("party")
