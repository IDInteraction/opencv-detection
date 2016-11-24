readfeature <- function(csvfile,
                        headerrow = c("frame", "x", "y", "w", "h")){
  outfile <- read.csv(csvfile, col.names = headerrow)
}


countfeatureframe <- function(indata){

  return(table(table(indata$frame)))

}


# Convert x,y, width and height data the x and y coordinates of the 4 vertices
# Format appears to be top left then anti-clockwise
getvertices <- function(indata){

  vertices <- c(
                indata['x'], indata['y'] + indata['h'],
                indata['x'], indata['y'],
                indata['x'] + indata['w'], indata['y'],
                indata['x'] + indata['w'], indata['y'] + indata['h']
                )



  names(vertices) <- c("v1x", "v1y",
                       "v2x", "v2y",
                       "v3x", "v3y",
                       "v4x", "v4y")

  return(vertices)
}

getmidpoint <- function(indata){

  midpoint <- c(indata['x'] + indata['w'] / 2,
                indata['y'] + indata['h'] / 2)

  names(midpoint) <- c("mx", "my")

  return(midpoint)
}


getMultiFaceFrames <- function(framedata){
  # multiface <- sqldf::sqldf("select Frame, count(*)
  #                           from framedata
  #                           group by Frame
  #                           having count(*) >1")$Frame

  freqtab <- as.data.frame(table(framedata$Frame))
  multiface <- as.integer(freqtab[freqtab$Freq > 1 , 1])
  return(multiface)

}

# Convert the openmp data csv to CppMT format
generateCppMTcsv <- function(indata, outfile, deltaframe = 20 ){

  midpoints <- data.frame(t(apply(indata, 1, getmidpoint)))
  vertices <- data.frame(t(apply(indata, 1, getvertices)))


  outdata <- cbind(indata$frame,
                   indata$frame * deltaframe + deltaframe,
                   rep(0, nrow(indata)) ,# dummy for Active.points
                   midpoints,
                   indata$w,
                   indata$h,
                   rep(0, nrow(indata)), # dummy for rotation
                   vertices
  )

  colnames <- c("Frame",
                "Timestamp (ms)",
                "Active points",
                "Bounding box centre X (px)",
                "Bounding box centre Y (px)",
                "Bounding box width (px)",
                "Bounding box height (px)",
                "Bounding box rotation (degrees)",
                "Bounding box vertex 1 X (px)",
                "Bounding box vertex 1 Y (px)",
                "Bounding box vertex 2 X (px)",
                "Bounding box vertex 2 Y (px)",
                "Bounding box vertex 3 X (px)",
                "Bounding box vertex 3 Y (px)",
                "Bounding box vertex 4 X (px)",
                "Bounding box vertex 4 Y (px)"
  )
  colnames(outdata) <- colnames

  twofaced <- getMultiFaceFrames(outdata)

  # TODO handle these better; ideally want to keep the face nearest the face on the
  # previous frame
  if(length(twofaced) > 0){
    warning(paste(length(twofaced), "frames with >1 face detected.  Dropping all faces from these frames"))
    outdata <- outdata[-which(outdata$Frame %in% twofaced), ]
  }

  write.table(outdata, file = outfile, col.names = colnames, row.names = FALSE,
              sep=",")

}
