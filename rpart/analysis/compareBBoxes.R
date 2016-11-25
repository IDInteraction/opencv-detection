# Compare the centre and size of the object-tracking BB to the face-detection BB
library(IDInteraction)
library(sqldf)
library(dplyr)
library(stringr)
library(ggplot2)
rm(list=ls())

trainingtimes <- c(1,2,5,10)
participants <- getParticipantCodes("/mnt/IDInteraction/dual_screen_free_experiment/attention/")



objectTrackFaceLoc <- "/mnt/IDInteraction/dual_screen_free_experiment/tracking/high_quality/front_full_face/"
objectDetectFaceLoc <- "~/opencv/abc-classifier/processall/"
annoteLoc <- "/mnt/IDInteraction/dual_screen_free_experiment/attention/"

allparticipantsTrackFace <- loadExperimentData(participants,
                                               trackingLoc = objectTrackFaceLoc,
                                               annoteLoc = annoteLoc  )

allparticipantsTrackFace <- renameVariables(allparticipantsTrackFace, prefix = "track")

allparticipantsDetectFace <- loadExperimentData(participants,
                                                trackingLoc = objectDetectFaceLoc,
                                                annoteLoc = annoteLoc,
                                                trackingSuffix = "face.csv"
)

allparticipantsDetectFace <- renameVariables(allparticipantsDetectFace, prefix = "detect")



# Face tracking will have something for every frame, so left join face-detection, which
# won't have anything when no face detected
detectnames <- names(allparticipantsDetectFace)
detectvarstring <- paste(detectnames[!is.na(str_match(detectnames, "^detect"))], collapse = ", ")

combinedparticipants <- sqldf(paste("select t.*, ", detectvarstring, 
                                    "from allparticipantsTrackFace as t",
                                    "left join",
                                    "allparticipantsDetectFace as d",
                                    "on t.timestampms == d.timestampms",
                                    "and t.participantCode = d.participantCode")
)

# TODO Deal with these in processing pipeline; they should have been removed then!
dupface <- sqldf("select timestampms, participantCode from combinedparticipants
             group by timestampms, participantCode
             having count(*) >1")

combinedparticipants <- sqldf("select * from combinedparticipants as c
                                where not exists(
                               select 1 from dupface as d 
                               where d.timestampms = c.timestampms and 
                               d.participantCode = c.participantCode)")


combinedparticipants$bbcdiff <- with(combinedparticipants,
                                     sqrt((trackboxXcoord - detectboxXcoord)^2 +
                                            (trackboxYcoord - detectboxYcoord)^2))

#plot(combinedparticipants$bbcdiff, type= "l" )

# ggplot(data=combinedparticipants,
#        aes(x=timestampms, y=bbcdiff)) + geom_line() +
#   facet_wrap(~participantCode)


trackDetectFormula <- attentionName ~ trackboxHeight +  trackboxRotation + 
  trackboxArea + trackboxWidth + trackwidthHeightRatio + trackboxYcoordRel + 
  detectboxArea + detectboxXcoordRel + detectboxYcoordRel


allresults <- NULL
for(p in participants){
  thisparticipant <- subset(combinedparticipants, combinedparticipants$participantCode == p)
  
  for(tt in trainingtimes){
    accuracy <- getAccuracy(getConfusionMatrix(thisparticipant, trainingtime = tt,
                                               formula = trackDetectFormula))
    allresults <- rbind(allresults, 
                        data.frame(participant = p,
                                   trainingtime = tt,
                                   accuracy = accuracy)
    )
  }
  
  # print(p)
}

tableTrackDetect<- sqldf("select trainingtime, avg(accuracy) as avgaccuracy 
                       from allresults
                       group by trainingtime")


save(tableTrackDetect, combinedparticipants, trackDetectFormula, file = "TrackDetect.RData")


