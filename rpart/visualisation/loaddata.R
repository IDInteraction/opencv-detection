library(ggplot2)
library(stringr)
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


getconfusionProp <- function(x, 
                             predcol = "origPred", 
                             obscol = "observedAttentionName"){
  cm <- table(x[,obscol], x[,predcol])
  
  return(cm/sum(cm))
}


getPredictions <- function(indata,
                           predictiontypes = c("origPred", "OpenCVPred", "SetBBPred")){
  
  
  preds <- lapply(predictiontypes, function(x){data.frame(getconfusionProp(indata, predcol = x))} )
  names(preds) <- predictiontypes
  
  predsDF <- do.call("rbind", preds)
  
  predsDF$method <- factor(str_match(row.names(predsDF), "(\\w+)\\.")[,2])
  colnames(predsDF) <- c("obs","pred", "prop", "method")
  
  return(predsDF)
  
}


