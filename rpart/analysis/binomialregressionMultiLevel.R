# Binomial mixed-effect model

library(lme4)


trainingdata <- allparticipantsNoElsewhere[flagtraining(allparticipantsNoElsewhere, 1),]
predictiondata <- allparticipantsNoElsewhere[!flagtraining(allparticipantsNoElsewhere,1), ]

# Treat participant code as an indicator variable - fixed-effect model
fitGlm <- glm(attentionIpad ~ ffboxHeight +   ffboxRotation +  
                ffboxWidth + ffwidthHeightRatio + ffboxYcoordRel + participantCode,
              data=allparticipantsNoElsewhere,
              family=binomial
)



glmpreds <- data.frame(participantCode = predictiondata$participantCode,
                       timestampms = predictiondata$timestampms,
                       predprob = predict(fitGlm, 
                                          newdata = predictiondata,
                                          type="response"))

predictiondata$prediction <- factor(ifelse(glmpreds$predprob < 0.5, "tv", "ipad"),
                                    levels = levels(allparticipantsNoElsewhere$attentionName))

accuracy <- getAccuracy(with(predictiondata, table(attentionName, prediction)))

accuracyByParticipant <- unlist(by(predictiondata, predictiondata$participantCode, 
   function(x){getAccuracy(with(x, table(attentionName, prediction)))}, simplify = FALSE))

mean(accuracyByParticipant)


# Fit varying intercept model
fitGlmer <- glmer(attentionIpad ~ ffboxHeight +   ffboxRotation +  
                ffboxWidth + ffwidthHeightRatio + ffboxYcoordRel + (1|participantCode) ,
              data=allparticipantsNoElsewhere,
              family=binomial
)

glmerpreds <- data.frame(participantCode = predictiondata$participantCode,
                       timestampms = predictiondata$timestampms,
                       predprob = predict(fitGlmer, 
                                          newdata = predictiondata,
                                          type="response"))

predictiondata$predictionGlmer <- factor(ifelse(glmerpreds$predprob < 0.5, "tv", "ipad"),
                                    levels = levels(allparticipantsNoElsewhere$attentionName))

accuracyGlmer <- getAccuracy(with(predictiondata, table(attentionName, predictionGlmer)))

accuracyByParticipantGlmer <- unlist(by(predictiondata, predictiondata$participantCode, 
                                   function(x){getAccuracy(with(x, 
                                                                table(attentionName,
                                                                      predictionGlmer)))}, 
                                   simplify = FALSE))

mean(accuracyByParticipantGlmer)

accuracyByParticipant
accuracyByParticipantGlmer



