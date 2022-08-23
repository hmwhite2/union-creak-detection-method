### This script creates the union of AM and CD over all data. 
### You will need the outputs of get_am_output_alldata.R and get_cd_output_alldata.R

### Make sure all your files are in the same working directory and set that here:
setwd("~/Downloads/wav/")
###

### load required libraries
library(dplyr)
###

### read in AM csv files
file_list = list.files(pattern = "*_below_am.csv")
data_list=lapply(file_list, read.table, header = T, sep = ",")
for (i in 1:length(data_list)){
  data_list[[i]]<-cbind(data_list[[i]],file_list[i])
  names(data_list[[i]]) <- c("speaker", "time", "creak", "file1")
}
below_am <- do.call("rbind", data_list)
below_am %>% 
  select(speaker, time, creak) %>% 
  rename(below_am = creak) -> below_am

### read in CD csv files
file_list = list.files(pattern = "*_cd.csv")
data_list=lapply(file_list, read.table, header = T, sep = ",")
for (i in 1:length(data_list)){
  data_list[[i]]<-cbind(data_list[[i]],file_list[i])
  names(data_list[[i]]) <- c("speaker", "time", "creak", "file1")
}
cd <- do.call("rbind", data_list)
cd %>% 
  select(speaker, time, creak) %>% 
  rename(creak_detector = creak) -> cd

### combine AM and CD
combined <- merge(below_am, cd, by = c("speaker", "time"))
combined$union <- ifelse(combined$below_am == 1 | combined$creak_detector == 1, 1, 0)

write.csv(combined, file = "union_method.csv", row.names = F)

