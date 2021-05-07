data <- read.table("Simulation_results_long.txt",sep="\t",header=TRUE)

library(psych)
library(car)
library(ggplot2)

data$model<-factor(data$files)
data$parameter <- factor(data$kind)

######## subsequently insert models 1 to 9:
levels(data$model)
levels(data$model)[9]

mod <- data[data$model == levels(data$model)[1],]
mod <- data[data$model == levels(data$model)[2],]
mod <- data[data$model == levels(data$model)[3],]
mod <- data[data$model == levels(data$model)[4],]
mod <- data[data$model == levels(data$model)[5],]
mod <- data[data$model == levels(data$model)[6],]
mod <- data[data$model == levels(data$model)[7],]
mod <- data[data$model == levels(data$model)[8],]
mod <- data[data$model == levels(data$model)[9],]

############# Boxplots (across all parameters per condition)

p1 <- ggplot(mod, aes(x=parameter,y=cover_95, fill = parameter)) + 
  geom_boxplot(outlier.colour="red", #outlier.shape=8,
               outlier.size=0.2,notch=F) + 
  scale_fill_manual(values=c("#003366", "#006699","#3399CC","#99CCFF","#CCFFFF"))+
  theme_bw()+
  theme(strip.text.x = element_text(size=12,face="bold"),
        strip.text.y = element_text(size=12, face="bold",angle=90),
        strip.background = element_rect(colour="darkblue"),  
        text = element_text(size=12),
        axis.text.x = element_text(size=9,face="bold", angle=45,hjust = 1),
        axis.text.y = element_text(size=12,face="bold"),
        axis.title.x = element_blank(),
        axis.title.y = element_text(face="bold",size=14,margin=margin(0,15,0,0)))+
  theme(panel.background = element_rect(colour = 'darkblue'))+
  ylab("95%-Coverage")+
  theme(plot.title = element_text(margin=margin(0,0,15,0),face="bold")) +
  theme(legend.key.size=unit(1.7,"lines")) + 
  geom_abline(intercept = .91, slope = 0,colour="red",size=0.5)+   
  geom_abline(intercept = .98, slope = 0,colour="red",size=0.5)+
  geom_abline(intercept = 0, slope = 0,colour="darkgrey",size=0.5)+
  coord_cartesian(ylim=c(.8,1))+
  theme(legend.position="none")


p2 <- ggplot(mod, aes(x=parameter,y=peb, fill = parameter)) + 
  geom_boxplot(outlier.colour="red", #outlier.shape=8,
               outlier.size=0.2,notch=F) + 
  scale_fill_manual(values=c("#003366", "#006699","#3399CC","#99CCFF","#CCFFFF"))+
  theme_bw()+
  theme(strip.text.x = element_text(size=12,face="bold"),
        strip.text.y = element_text(size=12, face="bold",angle=90),
        strip.background = element_rect(colour="darkblue"),  
        text = element_text(size=12),
        axis.text.x = element_text(size=9,face="bold", angle=45,hjust = 1),
        axis.text.y = element_text(size=12,face="bold"),
        axis.title.x = element_blank(),
        axis.title.y = element_text(face="bold",size=14,margin=margin(0,15,0,0)))+
  theme(panel.background = element_rect(colour = 'darkblue'))+
  ylab("relative parameter estimation bias")+
  theme(plot.title = element_text(margin=margin(0,0,15,0),face="bold")) +
  theme(legend.key.size=unit(1.7,"lines")) + 
  geom_abline(intercept = .1, slope = 0,colour="red",size=0.5)+
  geom_abline(intercept = 0, slope = 0,colour="darkgrey",size=0.5)+
  coord_cartesian(ylim=c(0,0.5))+
  theme(legend.position="none")

p3 <- ggplot(mod, aes(x=parameter,y=mse,fill=parameter)) + 
  geom_boxplot(outlier.colour="red", #outlier.shape=8,
               outlier.size=0.2,notch=F) + 
  scale_fill_manual(values=c("#003366", "#006699","#3399CC","#99CCFF","#CCFFFF"))+
  theme_bw()+
  theme(strip.text.x = element_text(size=12,face="bold"),
        strip.text.y = element_text(size=12, face="bold",angle=90),
        strip.background = element_rect(colour="darkblue"),  
        text = element_text(size=12),
        axis.text.x = element_text(size=9,face="bold", angle=45, hjust = 1),
        axis.text.y = element_text(size=12,face="bold"),
        axis.title.x = element_blank(),
        axis.title.y = element_text(face="bold",size=14,margin=margin(0,15,0,0)))+
  theme(panel.background = element_rect(colour = 'darkblue'))+
  ylab("Mean Squared Error")+
  theme(plot.title = element_text(margin=margin(0,0,15,0),face="bold")) +
  theme(legend.key.size=unit(1.7,"lines")) + 
  geom_abline(intercept = 0, slope = 0,colour="darkgrey",size=0.5)+
  coord_cartesian(ylim=c(0,2))+
  theme(legend.position="none")

p4 <- ggplot(mod, aes(x=parameter,y=bias,fill=parameter)) + 
  geom_boxplot(outlier.colour="red", #outlier.shape=8,
               outlier.size=0.2,notch=F) + 
  scale_fill_manual(values=c("#003366", "#006699","#3399CC","#99CCFF","#CCFFFF"))+
  theme_bw()+
  theme(strip.text.x = element_text(size=12,face="bold"),
        strip.text.y = element_text(size=12, face="bold",angle=90),
        strip.background = element_rect(colour="darkblue"),  
        text = element_text(size=12),
        axis.text.x = element_text(size=9,face="bold", angle=45,hjust = 1),
        axis.text.y = element_text(size=12,face="bold"),
        axis.title.x = element_blank(),
        axis.title.y = element_text(face="bold",size=14,margin=margin(0,15,0,0)))+
  theme(panel.background = element_rect(colour = 'darkblue'))+
  ylab("Bias")+
  theme(plot.title = element_text(margin=margin(0,0,15,0),face="bold")) +
  theme(legend.key.size=unit(1.7,"lines")) + 
  geom_abline(intercept = 0, slope = 0,colour="darkgrey",size=0.5)+
  coord_cartesian(ylim=c(-1,1))+
  theme(legend.position="none")

p5 <- ggplot(mod, aes(x=parameter,y=seb,fill=parameter)) + 
  geom_boxplot(outlier.colour="red", #outlier.shape=8,
               outlier.size=0.2,notch=F) + 
  scale_fill_manual(values=c("#003366", "#006699","#3399CC","#99CCFF","#CCFFFF"))+
  theme_bw()+
  theme(strip.text.x = element_text(size=12,face="bold"),
        strip.text.y = element_text(size=12, face="bold",angle=90),
        strip.background = element_rect(colour="darkblue"),  
        text = element_text(size=12),
        axis.text.x = element_text(size=9,face="bold", angle=45, hjust = 1),
        axis.text.y = element_text(size=12,face="bold"),
        axis.title.x = element_blank(),
         axis.title.y = element_text(face="bold",size=14,margin=margin(0,15,0,0)))+
  theme(panel.background = element_rect(colour = 'darkblue'))+
  ylab("relative standard error bias")+
  theme(plot.title = element_text(margin=margin(0,0,15,0),face="bold")) +
  theme(legend.key.size=unit(1.7,"lines")) + 
  geom_abline(intercept = .1, slope = 0,colour="red",size=0.5)+
  geom_abline(intercept = 0, slope = 0,colour="darkgrey",size=0.5)+
    coord_cartesian(ylim=c(0,1))+
  theme(legend.position="none")

grid.arrange(arrangeGrob(p1,p2, p3, p4, p5,ncol=5,widths=c(1/5,1/5, 1/5,1/5,1/5)))
