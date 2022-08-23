### This script finds the optimal threshold for CD for your data if you are conducting the 
### analysis over all data. It requires TextGrids that have been manually annotated for 
### creak and the output of CD at each threshold of the sweep for each file.  
### In TextGrids, the tier that contains manual annotation is labelled "creak". 
### There are points in the scripts where you may need to change the regex to match your 
### file names. These are noted in the script on lines 37, 40, 49 and 64.

### Make sure these files are saved in the same place and set that as your working directory 
### here:
setwd("~/OneDrive - Macquarie University/PhD/Study_3/CD/thres_sweep/handcoded_sample_f2f/")
###

### load required libraries
library(rPraat)
library(dplyr)
library(ggplot2)
###

### read in output of CD sweep
file_list <- list.files(pattern="*.txt")
data_list=lapply(file_list, read.table, header = T, sep = ",")
for (i in 1:length(data_list)){
  data_list[[i]]<-cbind(data_list[[i]],file_list[i])
}

for(i in 1:length(data_list)){
  names(data_list[[i]])[1] <- "time"
  names(data_list[[i]])[2] <- "creak_detector"
  names(data_list[[i]])[3] <- "speaker"
}

sweep <- do.call("rbind", data_list)

### get speaker info and threshold info into different columns
sweep$speaker <- gsub(".txt", "", sweep$speaker)
sweep$thres <- sweep$speaker
sweep$thres <- gsub("S\\d+_\\w_", "", sweep$thres) # adjust regex to fit your file names
sweep$thres <- gsub("_", ".", sweep$thres)
sweep$thres <- as.factor(sweep$thres)
sweep$speaker <- gsub("_\\w_0_\\d+$", "", sweep$speaker) # adjust regex to fit your file names
sweep$speaker <- as.factor(sweep$speaker)
sweep <- sweep[c(3,4,1,2)]

### get handcoding from TextGrids
files <- list.files(pattern = "*.TextGrid")
hc_all <- c()
for(i in 1:length(files)){
  temp_data <- tg.read(files[i]) %>%
    tg.removeTier("ORT-MAU")  # remove additional tiers in your textgrid
  temp_data$creak$file <- gsub(".TextGrid", "", files[i])
  
  hc_all <- rbind(hc_all, temp_data)
}

hc_df <- as.data.frame(c())
for(i in 1:length(hc_all)){
  data <- data.frame(cbind(speaker = hc_all[[i]]$file,
                           t1 = hc_all[[i]]$t1,
                           t2 = hc_all[[i]]$t2,
                           label = hc_all[[i]]$label))
  hc_df <- rbind(hc_df, data)
}

hc_df$speaker <- gsub("_\\w-hc", "", hc_df$speaker) # adjust regex to fit your file names
hc_speaker <- split(hc_df, hc_df$speaker)

hc <- as.data.frame(c())

for(j in 1:length(hc_speaker)){
  creak_intervals <- data.frame(cbind(hc_vec1 = hc_speaker[[j]]$t1,
                                      hc_vec2 = hc_speaker[[j]]$t2,
                                      hc_label = hc_speaker[[j]]$label))
  creak_intervals$hc_vec1 <- as.numeric(as.character(creak_intervals$hc_vec1))
  creak_intervals$hc_vec2 <- as.numeric(as.character(creak_intervals$hc_vec2))
  
  start <- min(creak_intervals$hc_vec1)
  end <- round(max(creak_intervals$hc_vec2), digits = 2)
  time <- round(seq(from = start, to = end, by = 0.01), digits = 2)
  creak <- as.data.frame(time, header = T)
  
  
  for(k in 1:nrow(creak_intervals)){
    intStart <- round(creak_intervals$hc_vec1[k], digits = 2)
    intEnd <- round(creak_intervals$hc_vec2[k], digits = 2)
    c <- creak_intervals$hc_label[k]
    creak$creak[creak$time >= intStart & creak$time <= intEnd] <- c
  }
  
  creak$speaker <- unique(hc_speaker[[j]]$speaker)
  creak <- creak[c(3,1,2)]
  hc <- rbind(hc, creak)
}

hc %>% 
  mutate_all(na_if,"") -> hc
hc$handcoded <- ifelse(is.na(hc$creak), 0, 1)
hc$creak <- NULL

### tidy cd files
hc %>% 
  group_by(speaker) %>% 
  mutate(start = 0) %>% 
  mutate(end = max(time)) %>% 
  select(speaker, start, end) %>% 
  unique(.) -> lims

creak_detector_1 <- merge(sweep, lims, by = "speaker")
creak_detector_1$speaker <- droplevels(creak_detector_1$speaker)

creak_detector_speaker <- split(creak_detector_1, creak_detector_1$speaker)
creak_detector_all <- as.data.frame(c())

for(m in 1:length(creak_detector_speaker)){
  creak_detector_2 <- data.frame(thres = creak_detector_speaker[[m]]$thres, 
                                 time = creak_detector_speaker[[m]]$time, 
                                 creak_detector = creak_detector_speaker[[m]]$creak_detector)
  
  start <- unique(creak_detector_speaker[[m]]$start)
  end <- round(unique(creak_detector_speaker[[m]]$end), digits = 2)
  time <- seq(from = start, to = end, by = 0.01)
  creak_detector_3 <- as.data.frame(time, header = T)
  
  thres_current <- split(creak_detector_2, creak_detector_2$thres)
  creak_detector_4 <- as.data.frame(c())
  
  for(n in 1:length(thres_current)){
    creak_detector_3$creak_detector <- NA
    decisions <- data.frame(time = thres_current[[n]]$time, 
                            thres = thres_current[[n]]$thres, 
                            creak_detector = thres_current[[n]]$creak_detector)
    decisions$time <- as.numeric(as.character(decisions$time))
    decisions <- filter(decisions, creak_detector == 1)
    
    for(k in 1:nrow(decisions)){
      creak_decision <- decisions$time[k]
      creak_detector_3$creak_detector[creak_detector_3$time == creak_decision] <- 1
      
      creak_detector_3$creak_detector[is.na(creak_detector_3$creak_detector)] <- 0
    }
    
    creak_detector_3$thres <- unique(thres_current[[n]]$thres)
    creak_detector_3$speaker <- unique(creak_detector_speaker[[m]]$speaker)
    creak_detector_4 <- rbind(creak_detector_4, creak_detector_3)
  }
  creak_detector_all <- rbind(creak_detector_all, creak_detector_4)
}

### compare cd performance across thresholds
all_data <- merge(hc, creak_detector_all, by = c("speaker", "time"), all.y = T)
all_data$code <- paste(all_data$handcoded, all_data$creak_detector)
all_data$code <- as.factor(all_data$code)
all_data$TN_count <- ifelse(all_data$code == "0 0", 1, 0)
all_data$TP_count <- ifelse(all_data$code == "1 1", 1, 0)
all_data$FN_count <- ifelse(all_data$code == "1 0", 1, 0)
all_data$FP_count <- ifelse(all_data$code == "0 1", 1, 0)

### this plots threshold sweeps across all speakers together
all_data %>% 
  group_by(thres) %>% 
  mutate(TP_count_thres = sum(TP_count)) %>% 
  mutate(FP_count_thres = sum(FP_count)) %>%
  mutate(FN_count_thres = sum(FN_count)) %>%
  mutate(TN_count_thres = sum(TN_count)) %>%
  select(thres, TP_count_thres, FP_count_thres, FN_count_thres, TN_count_thres) %>% 
  unique(.) -> thres_f1_all

thres_f1_all %>%
  mutate(f1 = (2*TP_count_thres)/(2*TP_count_thres+FP_count_thres+FN_count_thres)) -> thres_f1_all

ggplot(thres_f1_all, aes(x = thres, y = f1)) +
  geom_point() +
  theme_bw() +
  theme(axis.text.x = element_text(size = 12,
                                   angle = 45,
                                   hjust = 1),
        axis.text.y = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.title = element_blank(),
        legend.text = element_text(size = 12)) +
  labs(y = expression(paste(italic("F"),"1 score")),
       x = "Threshold")

thres_f1_all %>% 
  ungroup() %>% 
  slice_max(n = 1, f1) %>% 
  select(thres) # this is your optimal threshold

### you may want to get optimal thresholds for different speaker groups (e.g. sex).
### to do this, you need to read in demographic info for your speakers, e.g.:
speaker_data <- read.csv("~/OneDrive - Macquarie University/PhD/Study_3/Speaker_data_MAE.csv")
speaker_data <- speaker_data[c(1,7)]
colnames(speaker_data) <- c("speaker", "gender")
speaker_data$speaker <- gsub("MAE_", "", speaker_data$speaker)

### and merge this with your sweep dataset
all_data <- merge(all_data, speaker_data, by = c("speaker"), all.x = T)

all_data %>% 
  group_by(gender, thres) %>% 
  mutate(TP_count_thres = sum(TP_count)) %>% 
  mutate(FP_count_thres = sum(FP_count)) %>%
  mutate(FN_count_thres = sum(FN_count)) %>%
  mutate(TN_count_thres = sum(TN_count)) %>% 
  select(thres, TP_count_thres, FP_count_thres, FN_count_thres, TN_count_thres, gender) %>%
  unique(.) -> gender_thres_f1

gender_thres_f1 %>%
  mutate(f1 = (2*TP_count_thres)/(2*TP_count_thres+FP_count_thres+FN_count_thres)) -> gender_thres_f1

ggplot(gender_thres_f1, aes(x = thres, y = f1)) +
  geom_point() +
  theme_bw() +
  theme(axis.text.x = element_text(size = 12,
                                   angle = 45,
                                   hjust = 1),
        axis.text.y = element_text(size = 12),
        axis.title = element_text(size = 14),
        legend.title = element_blank(),
        legend.text = element_text(size = 12)) +
  labs(y = expression(paste(italic("F"),"1 score")),
       x = "Threshold") +
  facet_grid(~gender)


gender_thres_f1 %>% 
  ungroup() %>% 
  group_by(gender) %>% 
  slice_max(n = 1, f1) %>% 
  select(thres) # these are your optimal thresholds by sex

