### This script generates TextGrids for each of your sound files with segment boundaries every 20s.
### These can then be used to segment sound files using the chunk_files.praat script, for running 
### through REAPER efficiently. There are points in the scripts where you may need to change the 
### regex to match your file names. These are noted in the script on line 19.

### To run this script you need to have a durations.txt file (from praat script, get_durations.praat) 
### with lengths of your sound files.
### Make sure the outputs of this script is saved in your working directory:
setwd("~/Downloads/demo/")
###

### load required libraries
library(dplyr)
library(rPraat)
###

lims <- read.delim("durations.txt", header = F, sep = "\t")
colnames(lims) <- c("speaker", "end")
lims$speaker <- gsub(".wav", "", lims$speaker) # adjust regex to fit your file names
start <- 0

for(i in 1:nrow(lims)){
  length <- lims$end[i]
  t1 <- as.data.frame(seq(0, length, by = 20))
  t1 <- rbind(t1, length)
  colnames(t1) <- c("t1")
  t1$t2 <- lead(t1$t1)
  tg <- head(t1, - 1)  
  tg$speaker <- lims$speaker[i]
  tg$row <- seq.int(nrow(tg)) 
  tg$label <- paste(tg$speaker, tg$row, sep = "_")
  
  name <- 'chunk'
  type <- 'interval'
  t1 <- tg$t1
  t2 <- tg$t2
  label <- tg$label
  
  tier <- list(name, type, t1, t2, label)
  names(tier) <- c("name", "type", "t1", "t2", "label")
  
  textgrid <- list(tier)
  names(textgrid) <- c("chunk")
  class(textgrid)["tmin"] <- start
  class(textgrid)["tmax"] <- length
  
  output_file <- paste0(lims$speaker[i],".TextGrid")
  tg.write(textgrid, file = output_file)
}



