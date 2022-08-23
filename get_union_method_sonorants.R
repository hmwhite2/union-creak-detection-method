### This script creates the union of AM and CD over sonorants only. 
### You will need the outputs of get_am_output_sonorants.R, get_cd_ouput.R and
### create_phoneme_files.R.
### Note that this script filters out sonorants based on the AusE model in MAUS. You may need
### to adjust the script to fit your language model. 

### Make sure all your files are in the same working directory and set that here:
setwd("~/Downloads/wav/")
###

### load required libraries
library(dplyr)
###

### read in AM csv files
file_list = list.files(pattern = "*_below_am_son.csv")
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

### read in phoneme csv files
file_list = list.files(pattern = "*_phoneme.csv")
data_list=lapply(file_list, read.table, header = T, sep = ",")
for (i in 1:length(data_list)){
  data_list[[i]]<-cbind(data_list[[i]],file_list[i])
  names(data_list[[i]]) <- c("speaker", "time", "phoneme", "file1")
}
phoneme <- do.call("rbind", data_list)
phoneme %>% 
  select(speaker, time, phoneme) -> phoneme

### combine AM and CD
combined <- merge(below_am, cd, by = c("speaker", "time"))
combined <- merge(combined, phoneme, by = c("speaker", "time"))

### adjust script here to filter out sonorants of your language model 
combined %>% 
  filter(phoneme == "{" | phoneme == "{I" | phoneme == "{O" | phoneme == "}:" | phoneme == "@" | 
           phoneme == "@}" | phoneme == "3:" | phoneme == "6" | phoneme == "6:" | phoneme == "Ae" | 
           phoneme == "e" | phoneme == "e:" | phoneme == "i" | phoneme == "I" | phoneme == "i:" | 
           phoneme == "I@" | phoneme == "j" | phoneme == "l" | phoneme == "m" | phoneme == "n" | 
           phoneme == "N" | phoneme == "O" | phoneme == "o:" | phoneme == "oI" | phoneme == "r\\" | 
           phoneme == "U" | phoneme == "u:" | phoneme == "w") -> sonorants

sonorants$union <- ifelse(sonorants$below_am == 1 | sonorants$creak_detector == 1, 1, 0)

write.csv(sonorants, file = "union_method_son.csv", row.names = F)


