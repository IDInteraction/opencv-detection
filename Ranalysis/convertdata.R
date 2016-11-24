#!/usr/bin/env Rscript

#  Convert data of the form 
# fame, x, y, w, h
# to the format used by CppMT

#https://www.r-bloggers.com/passing-arguments-to-an-r-script-from-command-lines/
args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
  # default output file
  args[2] = "out.txt"
}

message("In folder")
message(getwd())

source("./opencv/abc-classifier/Ranalysis/functions.R")

indata <- readfeature(args[1])

generateCppMTcsv(indata, args[2])


