library(stringr)
inputdir <- "/mnt/IDInteraction/dual_screen_free_experiment/video/experiment2_individual_streams/high_quality/front/"
#inputdir <- "~/opencv/abc-classifier/testdata/"
outputdir <- "~/opencv/abc-classifier/processall/"

videofiles <- list.files(inputdir, pattern = "P\\d+_video.mp4$")


for(v in videofiles){
  rootname <- str_extract(v, "(P\\d+)")
  facename <- paste0("face", rootname, ".csv")
  eyename <- paste0("eye", rootname, ".csv")
  
  cmd <- paste0("python ~/opencv/abc-classifier/dynamic/face.py ",
                   inputdir, v, " ",
                   outputdir, facename, " ",
                   outputdir, eyename)
  
  system(cmd)
  
  # convert to Cpp-mt format
  convertscript <- "~/opencv/abc-classifier/Ranalysis/convertdata.R"
  cmd <- paste0("Rscript ",
                convertscript,
                " ",
                outputdir, facename, " ",
                outputdir, "p", facename)
  system(cmd)                 
  
}

