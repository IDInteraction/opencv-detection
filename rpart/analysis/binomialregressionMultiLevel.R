# Binomial mixed-effect model

library(lme4)
library(rpart)
library(REEMtree)
library(formula.tools)
library(IDInteraction)
library(party)
library(sqldf)
rm(list=ls())


participants <- getParticipantCodes("/mnt/IDInteraction/dual_screen_free_experiment/tracking/high_quality/front_full_face/")
trainingtimes <- c(1,2,5,10)

trainingtime <- trainingtimes[1]

table1formula <- attentionName ~ boxHeight +  boxRotation + boxArea + boxWidth + widthHeightRatio + boxYcoordRel
binomialRegressionFormula <- attentionIpad ~ boxHeight +   boxRotation +  boxWidth + widthHeightRatio + boxYcoordRel 

allparticipants <- loadExperimentData(participants,
                                      trackingLoc = "/mnt/IDInteraction/dual_screen_free_experiment/tracking/high_quality/front_full_face/",
                                      annoteLoc = "/mnt/IDInteraction/dual_screen_free_experiment/attention/")




# Remove elsewheres so we have binary outcome
allparticipantsNoElsewhere <- allparticipants[-which(allparticipants$attentionName == "elsewhere") , ]
allparticipantsNoElsewhere$attentionName <- factor(allparticipantsNoElsewhere$attentionName)


trainingdata <- allparticipantsNoElsewhere[flagtraining(allparticipantsNoElsewhere, trainingtime),]
predictiondata <- allparticipantsNoElsewhere[!flagtraining(allparticipantsNoElsewhere, trainingtime), ]

# Treat participant code as an indicator variable - fixed-effect model
fitGlm <- glm(attentionIpad ~ boxHeight +   boxRotation +  
                boxWidth + widthHeightRatio + boxYcoordRel + participantCode,
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
lme4formula <- attentionIpad ~ boxHeight +   boxRotation +  
  boxWidth + widthHeightRatio + boxYcoordRel + (1|participantCode)

lme4formula2 <- attentionIpad ~ boxHeight +   boxRotation +  
  boxWidth +  boxYcoordRel + (frame | participantCode)

fitGlmer <- glmer(lme4formula2 ,
                  data=allparticipantsNoElsewhere,
                  family=binomial(link = "logit"),
                  verbose = TRUE
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


accuracyByParticipant
mean(accuracyByParticipant)
accuracyByParticipantGlmer
mean(accuracyByParticipantGlmer)



# require(rstanarm)
# # Fit varying intercept model
# t_prior <- student_t(df = 7, location = 0, scale = 2.5)
# fitrstanarm <- stan_glmer(attentionIpad ~ boxHeight +   boxRotation +  
#                     boxWidth + widthHeightRatio + boxYcoordRel + (1|participantCode) ,
#                   data=allparticipantsNoElsewhere,
#                   family=binomial(link = "logit"),
#                   prior = t_prior, prior_intercept = t_prior,
#                   chains = 4, cores = 4)
# 

