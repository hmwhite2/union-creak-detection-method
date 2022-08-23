### This script converts the raw output of REAPER into pitch mark files in csv format. You will
### need the files in this format to run either of the get_am_output scripts. 
### The code for calculating the gciDuration and local F0 were written by Katherine Dallaston 
### (Dallaston & Docherty, 2019).
### There are points in the scripts where you may need to change the regex to match your 
### file names. These are noted in the script on lines 28 and 29.

### To run this script you need to have the output from REAPER for all files saved in the same place.
### Set that as your working directory here:
setwd("~/Downloads/reaper/")
###

### load required libraries
library(dplyr)
library(tidyr)
library(rPraat)
library(modes)
###

### read in pm files from REAPER output - these are in 20s chunks so we will concatenate them
file_list = list.files(pattern = "*.wav.pm")
data_list=lapply(file_list, read.table, header = T, sep = " ")
for (i in 1:length(data_list)){
  data_list[[i]]<-cbind(data_list[[i]],file_list[i])
  names(data_list[[i]]) <- c("gciTime", "voicing", "gciDuration", "file")
}
pm_files <- do.call("rbind", data_list) 
pm_files$file <- gsub(".wav.pm", "", pm_files$file) # adjust regex to fit your file names
pm_files$file <- gsub("chunked_", "", pm_files$file) # adjust regex to fit your file names
pm_files %>% 
  separate(file, into = c("speaker", "file"), sep = "_") -> pm_files
pm_files <- pm_files[c("speaker", "file", "gciTime", "voicing", "gciDuration")]

pm_files$file <- as.numeric(pm_files$file)
pm_files %>% 
  group_by(speaker) %>% 
  arrange(speaker, file) -> pm_files

pm_files_list <- split(pm_files, pm_files$speaker)

pmData <- as.data.frame(c())

for(j in 1:length(pm_files_list)){
  file <- pm_files_list[[j]]$file
  gciTime <- pm_files_list[[j]]$gciTime
  voicing <- pm_files_list[[j]]$voicing
  gciDuration <- pm_files_list[[j]]$gciDuration
  
  data <- as.data.frame(cbind(file, gciTime, voicing, gciDuration))
  
  data <- data[order(data$file),]
  
  data$gciDuration <- -99
  data$"localf0" <- -99
  
  for (i in 1:(nrow(data)-1)) {
    if (data$voicing[i]==1 && data$voicing[i+1]==1) {
      data[i, "gciDuration"] <- data$gciTime[i+1]-data$gciTime[i] #calculate the gciDuration
      data[i, "localf0"] <- 1/(data$gciTime[i+1]-data$gciTime[i]) #calculate the local F0
    }
  }
  
  data$speaker <- unique(pm_files_list[[j]]$speaker)
  data <- data[c(6,1,2,3,4,5)]
  
  pmData <- rbind(pmData, data)
}

pmData_split <- split(pmData, pmData$speaker)

pmData_final <- as.data.frame(c())

for(i in 1:length(pmData_split)){
  current <- data.frame(cbind(file = pmData_split[[i]]$file, 
                              gciTime = pmData_split[[i]]$gciTime, 
                              voicing = pmData_split[[i]]$voicing,
                              gciDuration = pmData_split[[i]]$gciDuration,
                              localf0 = pmData_split[[i]]$localf0))
  
  current_split <- split(current, current$file)
  
  pmData2 <- data.frame()
  data2 <- data.frame(cbind(file = current_split[[1]]$file, 
                            gciTime = current_split[[1]]$gciTime, 
                            voicing = current_split[[1]]$voicing, 
                            gciDuration = current_split[[1]]$gciDuration,
                            localf0 = current_split[[1]]$localf0))
  
  pmData2 <- rbind(pmData2, data2)
  pmData2$time_new <- NA
  
  pmData2$gciTime <- as.numeric(pmData2$gciTime)
  
  maxTime <- max(pmData2$gciTime)
  
  
  for(k in 2:length(current_split)){
    data3 <- data.frame(cbind(file = current_split[[k]]$file, 
                              gciTime = current_split[[k]]$gciTime,
                              voicing = current_split[[k]]$voicing,
                              gciDuration = current_split[[k]]$gciDuration,
                              localf0 = current_split[[k]]$localf0))
    
    data3$gciTime <- as.numeric(data3$gciTime)
    
    for(l in 1:nrow(data3)){
      data3$time_new <- data3$gciTime + maxTime
    }
    
    maxTime <- max(data3$time_new)
    
    pmData2 <- rbind(pmData2, data3)
  }
  
  pmData2$speaker <- unique(pmData_split[[i]]$speaker)
  pmData2 %>% 
    mutate(time_new = coalesce(time_new, gciTime)) %>% 
    select(speaker, time_new, voicing, gciDuration, localf0) %>% 
    rename(time = time_new) -> pmData2
  
  pmData_final <- rbind(pmData_final, pmData2)
}

### this saves each speaker's unique pm file as a csv
pmData_final_split <- split(pmData_final, pmData_final$speaker)

for(i in 1:length(pmData_final_split)){
  speaker <- data.frame(cbind(speaker = pmData_final_split[[i]]$speaker,
                              time = pmData_final_split[[i]]$time,
                              voicing = pmData_final_split[[i]]$voicing,
                              gciDuration = pmData_final_split[[i]]$gciDuration,
                              localf0 = pmData_final_split[[i]]$localf0))
  
  file_name <- unique(pmData_final_split[[i]]$speaker)
  output_file <- paste0(file_name,"_pm.csv")
  
  write.csv(speaker, file = output_file, row.names = F)
}

