
# Copyright (c) 2016 The University of Manchester, UK.
#
# Licenced under LGPL version 2.1. See LICENCE for details.
#
# The IDInteraction Attention Classification was developed in the IDInteraction project, funded by the Engineering and Physical Sciences Research Council, UK through grant agreement number EP/M017133/1.
#
# Author: David Mawdsley

# Replicate figures for table 1 of paper - "all" data (i.e. robust + glitches)
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

allparticipants <- loadExperimentData(participants,
                                      trackingLoc = "/mnt/IDInteraction/dual_screen_free_experiment/tracking/high_quality/front_full_face/",
                                      annoteLoc = "/mnt/IDInteraction/dual_screen_free_experiment/attention/")


allresults <- NULL
allpredictions <- NULL
for(p in participants){
  thisparticipant <- subset(allparticipants, allparticipants$participantCode == p)

  for(tt in trainingtimes){


    thispred <- getPartitionPredictions(thisparticipant, tt, table1formula)

    accuracy <- getAccuracy(getConfusionMatrixPreds(thispred))

    modelpredictions  <- cbind(
      traintime = tt,
      thisparticipant[!flagtraining(thisparticipant, tt),
                      c("participantCode", "frame","timestampms")],
      thispred)

    modelpredictions$numpredclass <- as.numeric(modelpredictions$predclass)

#    write.csv(modelpredictions[,c("traintime","participantCode",
#                                 "frame", "timestampms",
#                                 "predclass", "numpredclass")],
#              file = paste0(p, "_", tt, "_", "predictions.csv"))

    allpredictions <- dplyr::bind_rows(allpredictions,
                            modelpredictions)


    allresults <- rbind(allresults,
                        data.frame(participantCode = p,
                                   trainingtime = tt,
                                   accuracy = accuracy))

  }

  print(p)
}

table1 <- sqldf("select trainingtime, avg(accuracy) as avgaccuracy
                       from allresults
                       group by trainingtime")

table1predictions <- allpredictions
save(table1, table1formula, table1predictions, file = "table1.RData")
