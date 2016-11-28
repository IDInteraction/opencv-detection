
# Copyright (c) 2016 The University of Manchester, UK.
#
# Licenced under LGPL version 2.1. See LICENCE for details.
#
# The IDInteraction Attention Classification was developed in the IDInteraction project, funded by the Engineering and Physical Sciences Research Council, UK through grant agreement number EP/M017133/1.
#
# Author: David Mawdsley

# Calculating the equivalent of table 1 from the paper using the OpenCV data
library(rpart)
library(REEMtree)
library(formula.tools)
library(IDInteraction)
library(party)
library(sqldf)
rm(list=ls())


participants <- getParticipantCodes("/mnt/IDInteraction/dual_screen_free_experiment/attention/")
trainingtimes <- c(1,2,5,10)
openCVFormula <- formula(attentionName ~ boxArea + boxXcoordRel + boxYcoordRel)
allparticipantsOpenCV <- loadExperimentData(participants,
                                            "~/opencv/abc-classifier/processall/",
                                            "/mnt/IDInteraction/dual_screen_free_experiment/attention/",
                                            trackingSuffix = "face.csv")


allresults <- NULL

# We exclude participant 9 since a face was almost never detected and so there is
# insufficient data to train the classifier
for(p in participants[participants != "P09"]){
  thisparticipant <- subset(allparticipantsOpenCV, allparticipantsOpenCV$participantCode ==p)
  
  for(tt in trainingtimes){
    accuracy <- getAccuracy(getConfusionMatrix(thisparticipant, trainingtime = tt,
                                               formula = openCVFormula))
    allresults <- rbind(allresults, 
                        data.frame(participant = p,
                                   trainingtime = tt,
                                   accuracy = accuracy)
    )
  }
  
  print(p)
}

tableOpenCV<- sqldf("select trainingtime, avg(accuracy) as avgaccuracy 
                       from allresults
                       group by trainingtime")


save(openCVFormula, tableOpenCV, file = "table1OpenCV.RData")


