
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
for(p in participants){
  thisparticipant <- subset(allparticipants, allparticipants$participantCode == p)
  
  for(tt in trainingtimes){
    accuracy <- getAccuracy(getConfusionMatrix(thisparticipant, trainingtime = tt,
                                               formula = table1formula))
    allresults <- rbind(allresults, 
                        data.frame(participant = p,
                                   trainingtime = tt,
                                   accuracy = accuracy)
    )
  }
  
  # print(p)
}

table1 <- sqldf("select trainingtime, avg(accuracy) as avgaccuracy 
                       from allresults
                       group by trainingtime")


save(table1, table1formula, file = "table1.RData")