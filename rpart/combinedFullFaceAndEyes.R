
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


participants <- getParticipantCodes("~/IDInteraction/tracking-analysis/Rnotebooks/resources/dual_screen_free_experiment/high_quality/front_full_face/")
trainingtimes <- c(1,2,5,10)


formula <- attentionName ~ ffboxHeight +   ffboxRotation + ffboxArea + ffboxWidth + ffwidthHeightRatio + ffboxYcoordRel +
  eyesboxHeight +   eyesboxRotation + eyesboxArea + eyesboxWidth + eyeswidthHeightRatio + eyesboxYcoordRel

allresults <- NULL
for(p in participants){
  thisparticipantFF <- createTrackingAnnotation(p,
                                                trackingLoc = "/mnt/IDInteraction/dual_screen_free_experiment/tracking/high_quality/front_full_face/",
                                                annoteLoc = "~/IDInteraction/tracking-analysis/Rnotebooks/resources/dual_screen_free_experiment/high_quality/attention/"
  )
  
  thisparticipantFF <- renameVariables(thisparticipantFF, prefix = "ff")
  
  thisparticipantEyes <- createTrackingAnnotation(p,
                                                  trackingLoc = "/mnt/IDInteraction/dual_screen_free_experiment/tracking/high_quality/front_eyes_only/",
                                                  annoteLoc = "~/IDInteraction/tracking-analysis/Rnotebooks/resources/dual_screen_free_experiment/high_quality/attention/"
  )
  
  thisparticipantEyes <- renameVariables(thisparticipantEyes, prefix = "eyes")
  
  combinedparticipant <- sqldf("select * 
                               from thisparticipantEyes as e 
                               natural join 
                               thisparticipantFF as f")

  
  for(tt in trainingtimes){
    accuracy <- getAccuracy(getConfusionMatrix(combinedparticipant, trainingtime = tt,
                                               formula = formula))
    allresults <- rbind(allresults,
                        data.frame(participant = p,
                                   trainingtime = tt,
                                   accuracy = accuracy)
    )
  }
  
  print(p)
}

tableCombined <- sqldf("select trainingtime, avg(accuracy) as avgaccuracy
                       from allresults
                       group by trainingtime")
