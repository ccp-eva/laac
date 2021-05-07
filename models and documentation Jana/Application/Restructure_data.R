setwd("~/Desktop/MPI Leipzig/data/neu")

library(readr)
library(reshape2)
library(car)

apes1 <- read_csv("laac_data_trial.csv")
neu <- apes1[c("time_point","subject","task","trial_time_point","code")]

neu$subject2 <- as.numeric(as.factor(neu$subject))
neu <- unique(neu)
neu$var <- paste("Y",neu$trial_time_point,neu$time_point,sep="_")

wide <- neu[c("subject2","task","var","code")]
wide <- dcast(wide,formula = subject2 + task ~ var)
wide$task <- recode(wide$task, recodes="'causality'=1;'gaze_following'=2;'inference'=3;'quantity'=4;
                        'switching_feature'=5;'switching_place'=6")

long <- neu[c("time_point","subject2","trial_time_point","task","code")]
long$task <- recode(long$task, recodes="'causality'='cause';'gaze_following'='gaze';'inference'='inf';'quantity'='quant';
                        'switching_feature'='switchF';'switching_place'='switchP'")
long <- dcast(long, formula = subject2 + time_point ~ task + trial_time_point)

write.table(wide, file = "apes_wide_neu.dat",quote=FALSE, na= "-99",col.names=FALSE,row.names=FALSE)
write.table(long, file = "apes_long_neu.dat",quote=FALSE, na= "-99",col.names=FALSE,row.names=FALSE)


