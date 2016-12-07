# Confusion matrix plot for each participant; original bounding box


library(ggplot2)
library(stringr)
library(sqldf)
rm(list=ls())
load("../analysis/table1.RData")
load("../analysis/table1SetBB.RData")
load("../analysis/table1OpenCVBB.RData")


comparepredictions <- sqldf("select a.traintime, a.participantCode, a.frame,
                            a.observedAttentionName, a.predclass as origPred,
                            b.predclass as OpenCVPred,
                            c.predclass as SetBBPred
                            from  table1predictions as a 
                            inner join 
                            table1predictionsOpenCVBB as b
                            on a.traintime = b.traintime and
                            a.participantCode = b.participantCode and
                            a.frame = b.frame
                            inner join 
                            table1predictionsSetBB as c
                            on a.traintime = c.traintime and
                            a.participantCode = c.participantCode and
                            a.frame = c.frame
                            ")

factorpred <- function(chrvar, levels){
  return(factor(chrvar, levels))
}

factlevs <- levels(comparepredictions$observedAttentionName)

comparepredictions$origPred <- factorpred(comparepredictions$origPred, factlevs)
comparepredictions$OpenCVPred <- factorpred(comparepredictions$OpenCVPred, factlevs)
comparepredictions$SetBBPred <- factorpred(comparepredictions$SetBBPred, factlevs)

participantpreds <- comparepredictions[comparepredictions$participantCode == "P01",]
participanttimepred <- participantpreds[participantpreds$traintime ==1 ,]

str(participanttimepred)

with(participanttimepred, plot(frame, observedAttentionName, pch=".") )

# Probably not going to be viable to look at wrt time; too much data

# Compute a confusion matrix for each participant and time combination
tt <- 1

timepreds <- comparepredictions[comparepredictions$traintime == tt , ]

splitpreds <- split(timepreds,  timepreds$participantCode)

participantConfusion <- lapply(splitpreds, 
                               function(x){
                                 table(x$observedAttentionName, x$origPred)}
                               )

participantNormalised <- lapply(participantConfusion, function(x){x/sum(x)})

# Make long for ggplot

test <- participantNormalised$P10
data.frame(test)

participantLong <- lapply(participantNormalised, function(x){data.frame(x)})
participantDF <- do.call("rbind", participantLong)

participantDF$participantCode <- factor(str_match(row.names(participantDF), "(\\w+)\\.")[,2])
colnames(participantDF) <- c("obs","pred", "prop", "participantCode")

# Levelplot with ggplot2

ggplot(participantDF, aes(obs, pred, z= prop)) + 
  geom_tile(aes(fill = prop)) + theme_bw() + facet_wrap(~participantCode) +
  scale_fill_gradient(low="white", high="black") 


