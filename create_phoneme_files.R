### This script creates time aligned phoneme csv files from annotated TextGrids that have been
### processed by MAUS.
### There are points in the scripts where you may need to change the regex to match your 
### file names. These are noted in the script on lines 48 and 49.


### To run this script you need to have TextGrids with the MAUS output in one directory:
setwd("~/Downloads/reaper/")
###

### load required libraries
library(dplyr)
library(tidyr)
library(rPraat)
###

files <- list.files(pattern = "*.TextGrid")
phonemes_all <- c()
for(i in 1:length(files)){
  temp_data <- tg.read(files[i]) %>%
    tg.removeTier("ORT-MAU") %>% tg.removeTier("KAN-MAU") %>% tg.removeTier("KAS-MAU") %>% tg.removeTier("MAS") %>% tg.removeTier("TRN")
  temp_data$MAU$file <- gsub(".TextGrid", "", files[i])
  
  phonemes_all <- rbind(phonemes_all, temp_data)
}

for(i in 1:length(phonemes_all)){
  data <- data.frame(cbind(phoneme_vec1 = phonemes_all[[i]]$t1,
                           phoneme_vec2 = phonemes_all[[i]]$t2,
                           phoneme_label = phonemes_all[[i]]$label))
  data$phoneme_vec1 <- as.numeric(data$phoneme_vec1)
  data$phoneme_vec2 <- as.numeric(data$phoneme_vec2)
  start <- min(data$phoneme_vec1)
  end <- round(max(data$phoneme_vec2), digits = 2)
  
  time <- round(seq(from = start, to = end, by = 0.01), digits = 2)
  phoneme <- as.data.frame(time, header = T)
  
  for(k in 1:nrow(data)){
    intStart <- round(data$phoneme_vec1[k], digits = 2)
    intEnd <- round(data$phoneme_vec2[k], digits = 2)
    p <- data$phoneme_label[k]
    phoneme$phoneme[phoneme$time >= intStart & phoneme$time <= intEnd] <- p
  }
  
  phoneme$speaker <- unique(phonemes_all[[i]]$file)
  phoneme <- phoneme[c(3,1,2)]
  phoneme$speaker <- gsub("MAE_", "", phoneme$speaker) # adjust regex to fit your file names
  phoneme$speaker <- gsub("_conv.pipeline", "", phoneme$speaker) # adjust regex to fit your file names
  
  output_file <- paste0(unique(phoneme$speaker),"_phoneme.csv")
  write.csv(phoneme, file = output_file, row.names = F)
}
