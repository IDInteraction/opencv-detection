library(stringr)


checkpath <- function(indir){
# removed since not dir.exists() not available in docker container
#  if(!dir.exists(indir)){
#    stop(paste(indir, "does not exist"))
#  }
  
  if(is.na(str_match(indir, "/$"))){
    indir <- paste0(indir, "/")
  }
  
  return(indir)
}



options <- commandArgs(trailingOnly = TRUE)
if(length(options) != 2){
  stop("Expecting input and output folders")
}

inputdir <- checkpath(options[1])
outputdir <- checkpath(options[2])


videofiles <- list.files(inputdir, pattern = "P\\d+_video.mp4$")


for(v in videofiles){
  rootname <- str_extract(v, "(P\\d+)")
  facename <- paste0("face", rootname, ".csv")
  eyename <- paste0("eye", rootname, ".csv")
  
  cmd <- paste0("python ./opencv/abc-classifier/dynamic/face.py ",
                   inputdir, v, " ",
                   outputdir, facename, " ",
                   outputdir, eyename)
  
  system(cmd)
  
  # convert to Cpp-mt format
  convertscript <- "./opencv/abc-classifier/Ranalysis/convertdata.R"
  cmd <- paste0("Rscript ",
                convertscript,
                " ",
                outputdir, facename, " ",
                outputdir, "p", facename)
  system(cmd)                 
  
}

