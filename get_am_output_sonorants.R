### This script generates the AM output from the REAPER output based only on sonorant segments.
### Note that this script filters out sonorants based on the AusE model in MAUS. You may need
### to adjust the script to fit your language model. The function for determining the modal mode,
### creaky mode and antimode were written by Katherine Dallaston (Dallaston & Docherty, 2019).

### To run this script you need to have run create_pm_files and create_phoneme_files on your data.
### Make sure the outputs of these scripts are saved in the same place and set that as your
### working directory here:
setwd("~/Downloads/wav/")
###

### load required libraries
library(stringr)
library(dplyr)
library(rPraat)
library(modes) # this package is archived and may need to be downloaded from https://CRAN.R-project.org/package=modes
###

### load in pm files and tidy
file_list = list.files(pattern = "*_pm.csv")
data_list=lapply(file_list, read.table, header = T, sep = ",")
for (i in 1:length(data_list)){
  data_list[[i]]<-cbind(data_list[[i]],file_list[i])
  names(data_list[[i]]) <- c("speaker", "time", "voicing", "gciDuration", "localf0", "file1")
}
pm_files <- do.call("rbind", data_list)
pm_files %>% 
  select(speaker, time, voicing, localf0) -> pm_files1

### load in phoneme files and filter it to include sonorants only
file_list = list.files(pattern = "*_phoneme.csv")
data_list=lapply(file_list, read.table, header = T, sep = ",")
for (i in 1:length(data_list)){
  data_list[[i]]<-cbind(data_list[[i]],file_list[i])
}
phonemes <- do.call("rbind", data_list) 
phonemes %>% 
  select(speaker, time, phoneme) -> phonemes

### adjust script here to filter out sonorants of your language model 
phonemes %>%
  filter(phoneme == "{" | phoneme == "{I" | phoneme == "{O" | phoneme == "}:" | phoneme == "@" | 
           phoneme == "@}" | phoneme == "3:" | phoneme == "6" | phoneme == "6:" | phoneme == "Ae" | 
           phoneme == "e" | phoneme == "e:" | phoneme == "i" | phoneme == "I" | phoneme == "i:" | 
           phoneme == "I@" | phoneme == "j" | phoneme == "l" | phoneme == "m" | phoneme == "n" | 
           phoneme == "N" | phoneme == "O" | phoneme == "o:" | phoneme == "oI" | phoneme == "r\\" | 
           phoneme == "U" | phoneme == "u:" | phoneme == "w") -> sonorants

pm_files1$time <- round(pm_files1$time, digits = 2)
pm_files1 %>% 
  filter(voicing == 1) -> pm_files1
pm_files1 <- merge(pm_files1, sonorants, by = c("speaker", "time"))
pm_files1 %>% 
  filter(localf0 > 0) -> pm_files1


### this is the function that determines the modal and creak modes and the antimode
findF0Antimode <- function (data){
  antimodeFloor <- 40 #some distributions are so totally uni-modal that no antimode is found at all, so you might want to set a 'default' here e.g. 40 Hz (because anything below 40Hz probably sounds creaky)
  modes <- amps (x = data)
  antimodes <- as.data.frame(modes$Antimode)
  
  #find the highest peak (this will be assumed to be in the modal phonation distribution)
  peaks <- as.data.frame(modes$Peaks)
  peaks <- peaks[order(peaks$`Amplitude (y)`, decreasing = T),]
  maxPeak <- peaks$`Location (x)`[1]
  
  if (nrow(antimodes[antimodes$`Location (x)`<maxPeak,])==0){ #if no antimode is found in the distribution at all
    if(sum(data < 40) == 0){
      f0Antimode <- 0
      secondMaxPeak <- 0
    } else{
      f0Antimode <- antimodeFloor
      secondMaxPeak <- 0
    }
  } else {
    #locoate all peaks to the left of the maxPeak
    peaksLeftofMaxPeak <- peaks[which(peaks$`Location (x)`<maxPeak),]
    peaksLeftofMaxPeak <- peaksLeftofMaxPeak[order(peaksLeftofMaxPeak$`Location (x)`, decreasing = T),]
    
    #test each peak (starting at the peak closest to maxPeak) to see if there's an antimode between them
    foundAntimode <- F
    loop <- 0
    while (foundAntimode==F) {
      loop <- loop+1
      
      secondMaxPeak <- peaksLeftofMaxPeak$`Location (x)`[loop]
      antimodesBetweenPeaks <- antimodes[antimodes$`Location (x)`<maxPeak,]
      antimodesBetweenPeaks <- antimodesBetweenPeaks[antimodesBetweenPeaks$`Location (x)`>secondMaxPeak,]
      antimodesBetweenPeaks <- antimodesBetweenPeaks[antimodesBetweenPeaks$`Amplitude (y)`<0.005,]
      
      foundAntimode <- nrow(antimodesBetweenPeaks)>0 #this will switch foundAntimode to "T" if an antimode is found
    }
    if(is.na(antimodesBetweenPeaks$`Location (x)`)){
      f0Antimode <- 0
      secondMaxPeak <- 0
    } else{
      f0Antimode <- antimodesBetweenPeaks$`Location (x)`[which(antimodesBetweenPeaks$`Amplitude (y)`==min(antimodesBetweenPeaks$`Amplitude (y)`))]
    }
  }
  results <- list(f0Antimode=f0Antimode, maxPeak=maxPeak, secondMaxPeak=secondMaxPeak)
  return(results)
}

### apply the above code to your data
pm_files1_speaker <- split(pm_files1, pm_files1$speaker)

son_am <- as.data.frame(c())

for(i in 1:length(pm_files1_speaker)){
  localf0 <- pm_files1_speaker[[i]]$localf0
  modes <- findF0Antimode(localf0)
  assumedModalMode <- modes$maxPeak
  assumedCreakMode <- modes$secondMaxPeak
  antimode <- modes$f0Antimode
  
  speaker <- pm_files1_speaker[[i]]$speaker
  time <- pm_files1_speaker[[i]]$time
  phoneme <- pm_files1_speaker[[i]]$phoneme
  
  son_am1 <- data.frame(cbind(speaker, time, localf0, phoneme))
  son_am1$antimode <- antimode 
  
  son_am <- rbind(son_am, son_am1)
}

son_am %>% 
  select(speaker, antimode) %>% 
  unique(.) -> son_am

pm_files %>% 
  select(speaker, time, localf0) -> pm_files

below.am <- merge(pm_files, son_am, by = c("speaker"))
below.am$below_am <- ifelse(below.am$localf0 < below.am$antimode & below.am$localf0 > 0, 1, 0)

phonemes %>% 
  group_by(speaker) %>% 
  mutate(start = 0) %>% 
  mutate(end = max(time)) %>% 
  select(speaker, start, end) %>% 
  unique(.) -> lims

### merge and tidy data
below.am$localf0 <- NULL
below.am$time <- round(below.am$time, digits = 2)
below.am <- merge(below.am, lims, by = c("speaker"))
below.am$start <- as.character(below.am$start)
below.am$end <- as.character(below.am$end)

## get intervals of "creak" for each file
below.am$creak_start <- (below.am$below_am == 1) & (c(0, diff(below.am$below_am)) == 1)
below.am$creak_end <- c(-1, diff(below.am$below_am)) == -1

starts <- below.am$time[below.am$creak_start]
file_start <- below.am$speaker[below.am$creak_start]
interval_start <- as.data.frame(cbind(file_start, starts))
colnames(interval_start) <- c("speaker", "interval_start")

ends <- below.am$time[below.am$creak_end]
file_end <- below.am$speaker[below.am$creak_end]
interval_end <- as.data.frame(cbind(file_end, ends))
colnames(interval_end) <- c("speaker", "interval_end")
interval_end <- interval_end[-c(1),]
rownames(interval_end) <- 1:nrow(interval_end)

intervals <- cbind(interval_start, interval_end)
intervals <- intervals[-c(3)]
intervals <- merge(intervals, lims, by = "speaker")
intervals$speaker <- as.character(intervals$speaker)
intervals$interval_start <- as.character(intervals$interval_start)
intervals$interval_end <- as.character(intervals$interval_end)
intervals$start <- as.numeric(as.character(intervals$start))
intervals$end <- as.numeric(as.character(intervals$end))

intervals_split <- split(intervals, intervals$speaker)

## loop through creak intervals for each speaker and assign creak decision to complete timestamped df
## save output

for(j in 1:length(intervals_split)){
  start <- unique(intervals_split[[j]]$start)
  end <- unique(intervals_split[[j]]$end)
  time <- seq(from = start, to = end, by = 0.01)
  below_am <- as.data.frame(time, header = T)
  
  below_am_intervals <- data.frame(cbind(below_am_vec1 = intervals_split[[j]]$interval_start,
                                         below_am_vec2 = intervals_split[[j]]$interval_end))
  below_am_intervals$below_am_vec1 <- as.numeric(as.character(below_am_intervals$below_am_vec1))
  below_am_intervals$below_am_vec2 <- as.numeric(as.character(below_am_intervals$below_am_vec2))
  
  below_am$creak <- NA
  
  for(k in 1:nrow(below_am_intervals)){
    intStart <- below_am_intervals$below_am_vec1[k]
    intEnd <- below_am_intervals$below_am_vec2[k]
    below_am$creak[below_am$time >= intStart & below_am$time <= intEnd] <- 1
    intEnd <- as.factor(below_am_intervals$below_am_vec2[k])
    below_am$creak[below_am$time == intEnd] <- 1
  }
  
  below_am$creak[is.na(below_am$creak)] <- 0
  
  below_am$speaker <- unique(intervals_split[[j]]$speaker)
  below_am <- below_am[c(3,1,2)]
  
  output_file <- paste0(unique(intervals_split[[j]]$speaker),"_below_am_son.csv")
  write.csv(below_am, file = output_file, row.names = F)
}

### for files that have no creak (unlikely in longer files)
intervals_names <- intervals[-c(2:5)]
intervals_names <- unique(intervals_names)
lims_2 <- lims %>%
  filter(!speaker %in% intervals_names$speaker)

for(m in 1:nrow(lims_2)){
  timestamps <- seq(from = lims_2$start[m], to = lims_2$end[m], by = 0.01)
  below_am <- as.data.frame(timestamps, header = T)
  below_am$creak <- 0
  
  output_file <- paste0(lims_2$speaker[m],"_below_am_son.csv")
  write.csv(below_am, file = output_file, row.names = F)
}









