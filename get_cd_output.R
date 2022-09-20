### This script tidies your raw CD output into csv files with timestamps that match the sound
### files and your AM analysis. You will need the CD .txt files and a durations.txt file which 
### can be made with the get_durations.praat script.
### There are points in the scripts where you may need to change the regex to match your 
### file names. These are noted in the script on lines 33, 34, 41, 60 and 61.

### To run this script you will need CD .txt files and .TextGrid files for each sound file 
### in the same directory:
setwd("~/Downloads/demo")
###

### load required libraries
library(dplyr)
###

### read in CD output
file_list <- list.files(pattern="*cd.txt") # adjust pattern to read in correct files
data_list=lapply(file_list, read.table, header = F, sep = ",")
for (i in 1:length(data_list)){
  data_list[[i]]<-cbind(data_list[[i]],file_list[i])
}

for(i in 1:length(data_list)){
  names(data_list[[i]])[1] <- "time"
  names(data_list[[i]])[2] <- "creak_detector"
  names(data_list[[i]])[3] <- "speaker"
}

cd_files <- do.call("rbind", data_list)

cd_files$speaker <- gsub("_passage_cd.txt", "", cd_files$speaker) # adjust regex to fit your file names

### read in duration info
lims <- read.delim("durations.txt", header = F, sep = "\t")
colnames(lims) <- c("speaker", "end")
lims$speaker <- gsub("_passage.wav", "", lims$speaker) # adjust regex to fit your file names
lims %>% 
  group_by(speaker) %>% 
  mutate(start = 0.01) %>% 
  mutate(end = round(max(end), digits = 2)) %>% 
  select(speaker, start, end) %>% 
  unique(.) -> lims

cd_files <- merge(cd_files, lims, by = c("speaker"), all.x = T)

cd_files_speaker <- split(cd_files, cd_files$speaker)
cd_files_all <- as.data.frame(c())

for(i in 1:length(cd_files_speaker)){
  cd_2 <- data.frame(time = cd_files_speaker[[i]]$time, 
                     creak_detector = cd_files_speaker[[i]]$creak_detector)
  
  start <- unique(cd_files_speaker[[i]]$start)
  end <- round(unique(cd_files_speaker[[i]]$end), digits = 2)
  time <- seq(from = start, to = end, by = 0.01)
  cd_3 <- as.data.frame(time, header = T)
  decisions <- filter(cd_2, creak_detector == 1)
  
  for(k in 1:nrow(decisions)){
    creak_decision <- decisions$time[k]
    cd_3$creak_detector[cd_3$time == creak_decision] <- 1
      
    cd_3$creak_detector[is.na(cd_3$creak_detector)] <- 0
  }
    
  cd_3$speaker <- unique(cd_files_speaker[[i]]$speaker)

  cd_files_all <- rbind(cd_files_all, cd_3)
}

cd_files_all <- cd_files_all[c(3,1,2)]

### save individual speaker files
cd_speaker <- split(cd_files_all, cd_files_all$speaker)

for(i in 1:length(cd_speaker)){
  df <- data.frame(cbind(speaker = cd_speaker[[i]]$speaker,
                         time = cd_speaker[[i]]$time,
                         creak_detector = cd_speaker[[i]]$creak_detector))

  output_file <- paste0(unique(cd_speaker[[i]]$speaker),"_cd.csv")
  write.csv(df, file = output_file, row.names = F)
}


