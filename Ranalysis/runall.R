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
if(length(options) != 3){
  stop("Expecting input, output and frameskip folders")
}

inputdir <- checkpath(options[1])
outputdir <- checkpath(options[2])
skipdir <- checkpath(options[3])


videofiles <- list.files(inputdir, pattern = "P\\d+_video.mp4$")


for(v in videofiles){
  rootname <- str_extract(v, "(P\\d+)")
  facename <- paste0(rootname, "face",  ".csv")
  eyename <- paste0(rootname, "eye", ".csv")
  skipname <- paste0(rootname, "_video.skip")
  cmd <- paste0("python $IDI_HOME/opencv/abc-classifier/dynamic/face.py ",
                   inputdir, v, " ",
                   outputdir, facename, " ",
                   outputdir, eyename, " ",
                   skipdir, skipname)

  system(cmd)

  # convert to Cpp-mt format
  convertscript <- "$IDI_HOME/opencv/abc-classifier/Ranalysis/convertdata.R"
  cmd <- paste0("Rscript ",
                convertscript,
                " ",
                outputdir, facename, " ",
                outputdir, facename)
  system(cmd)

}
