### This script finds the optimal threshold for CD for your data if you are conducting the 
### analysis over sonorants only. 
### It requires TextGrids that contain phoneme segments and have been manually annotated 
### for creak and the output of CD at each threshold of the sweep for each file. 
### In TextGrids, the tier that contains manual annotation is labelled "creak" and the tier
### that contains phoneme segments is labelled "MAU". 
### Note that this script filters out sonorants based on the AusE model in MAUS. You may need
### to adjust the script to fit your language model.
### There are points in the scripts where you may need to change the regex to match your 
### file names. These are noted in the script on lines 41, 44, 68 and 115.

### Make sure these files are saved in the same place and set that as your working directory 
### here:
setwd("~/Downloads/demo")
### 

### load required libraries
library(rPraat)
library(dplyr)
library(ggplot2)
###

### read in output of CD sweep
file_list <- list.files(pattern="*.txt")
data_list=lapply(file_list, read.table, header = F, sep = ",")
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
sweep$thres <- gsub("sample\\d_passage_", "", sweep$thres) # adjust regex to fit your file names
sweep$thres <- gsub("_", ".", sweep$thres)
sweep$thres <- as.factor(sweep$thres)
sweep$speaker <- gsub("_passage_0_\\d+$", "", sweep$speaker) # adjust regex to fit your file names
sweep$speaker <- as.factor(sweep$speaker)
sweep <- sweep[c(3,4,1,2)]

### read in textgrids to get phoneme tier
files <- list.files(pattern = "*pipeline.TextGrid")
phonemes_all <- c()
for(i in 1:length(files)){
  temp_data <- tg.read(files[i]) %>%
    tg.removeTier("ORT-MAU") %>% tg.removeTier("KAN-MAU") %>% tg.removeTier("KAS-MAU") %>% tg.removeTier("MAU") %>% tg.removeTier("MAS") %>% tg.removeTier("TRN") %>% tg.removeTier("creak")
  temp_data$SON$file <- gsub(".TextGrid", "", files[i])
  
  phonemes_all <- rbind(phonemes_all, temp_data)
}

phonemes_df <- as.data.frame(c())
for(i in 1:length(phonemes_all)){
  data <- data.frame(cbind(speaker = phonemes_all[[i]]$file,
                           t1 = phonemes_all[[i]]$t1,
                           t2 = phonemes_all[[i]]$t2,
                           label = phonemes_all[[i]]$label))
  phonemes_df <- rbind(phonemes_df, data)
}

phonemes_df$speaker <- gsub("_passage_pipeline", "", phonemes_df$speaker) # adjust regex to fit your file names
phonemes_speaker <- split(phonemes_df, phonemes_df$speaker)

phon <- as.data.frame(c())

for(j in 1:length(phonemes_speaker)){
  phoneme_intervals <- as.data.frame(cbind(phoneme_vec1 = phonemes_speaker[[j]]$t1,
                                           phoneme_vec2 = phonemes_speaker[[j]]$t2,
                                           phoneme_label = phonemes_speaker[[j]]$label))
  phoneme_intervals$phoneme_vec1 <- as.numeric(as.character(phoneme_intervals$phoneme_vec1))
  phoneme_intervals$phoneme_vec2 <- as.numeric(as.character(phoneme_intervals$phoneme_vec2))
  
  start <- min(phoneme_intervals$phoneme_vec1)
  end <- round(max(phoneme_intervals$phoneme_vec2), digits = 2)
  time <- round(seq(from = start, to = end, by = 0.01), digits = 2)
  phoneme <- as.data.frame(time, header = T)
  
  for(k in 1:nrow(phoneme_intervals)){
    intStart <- round(phoneme_intervals$phoneme_vec1[k], digits = 2)
    intEnd <- round(phoneme_intervals$phoneme_vec2[k], digits = 2)
    p <- phoneme_intervals$phoneme_label[k]
    phoneme$phoneme[phoneme$time >= intStart & phoneme$time <= intEnd] <- p
  }
  
  phoneme$speaker <- unique(phonemes_speaker[[j]]$speaker)
  phoneme <- phoneme[c(3,1,2)]
  phon <- rbind(phon, phoneme)
}

### get handcoding from TextGrids
hc_all <- c()
for(i in 1:length(files)){
  temp_data <- tg.read(files[i]) %>%
    tg.removeTier("ORT-MAU") %>% tg.removeTier("KAN-MAU") %>% tg.removeTier("KAS-MAU") %>% tg.removeTier("MAU") %>% tg.removeTier("SON") %>% tg.removeTier("MAS") %>% tg.removeTier("TRN")
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

hc_df$speaker <- gsub("_passage_pipeline", "", hc_df$speaker) # adjust regex to fit your file names
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

### combine phoneme and hc dfs
all_data <- merge(phon, hc, by = c("speaker", "time"))

### tidy cd files
all_data %>% 
  group_by(speaker) %>% 
  mutate(start = 0.01) %>% 
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
all_data2 <- merge(all_data, creak_detector_all, by = c("speaker", "time"), all.y = T)
all_data2$code <- paste(all_data2$handcoded, all_data2$creak_detector)
all_data2$code <- as.factor(all_data2$code)
all_data2$TN_count <- ifelse(all_data2$code == "0 0", 1, 0)
all_data2$TP_count <- ifelse(all_data2$code == "1 1", 1, 0)
all_data2$FN_count <- ifelse(all_data2$code == "1 0", 1, 0)
all_data2$FP_count <- ifelse(all_data2$code == "0 1", 1, 0)

all_data2 %>%
  filter(phoneme == "{" | phoneme == "{I" | phoneme == "{O" | phoneme == "}:" | phoneme == "@" | 
           phoneme == "@}" | phoneme == "3:" | phoneme == "6" | phoneme == "6:" | phoneme == "Ae" | 
           phoneme == "e" | phoneme == "e:" | phoneme == "i" | phoneme == "I" | phoneme == "i:" | 
           phoneme == "I@" | phoneme == "j" | phoneme == "l" | phoneme == "m" | phoneme == "n" | 
           phoneme == "N" | phoneme == "O" | phoneme == "o:" | phoneme == "oI" | phoneme == "r\\" | 
           phoneme == "U" | phoneme == "u:" | phoneme == "w") -> sonorants

### this plots threshold sweeps across all speakers together
sonorants %>% 
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

# speaker_data <- read.csv("~/OneDrive - Macquarie University/PhD/Study_3/Speaker_data_MAE.csv")
# speaker_data <- speaker_data[c(1,7)]
# colnames(speaker_data) <- c("speaker", "gender")
# speaker_data$speaker <- gsub("MAE_", "", speaker_data$speaker)

speaker_data <- data.frame(c("sample1", "sample2"),
                           c("Female", "Male"))
colnames(speaker_data) <- c("speaker", "gender")

### and merge this with your sweep dataset
sonorants <- merge(sonorants, speaker_data, by = c("speaker"), all.x = T)

sonorants %>% 
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

## for the demo data F opt thres: 0.03
## male opt thres: 0.14 and lower f1 scores - lower performance by CD on male speech is
## discussed in:
## White, H., Penney, J., Gibson, A., Szakay, A. & Cox, F. (2022). Evaluating automatic creaky 
##      voice detection methods. Journal of the Acoustical Society of America, 152(3).




