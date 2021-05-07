 library(tcltk)
 library(MplusAutomation)
 library(car)
 library(plyr)
 
 Files=dir(pattern="Simu.*\\.out",recursive=TRUE)
  
 AllModelParameters <- readModels(Files, what="parameters")
 
 unstandardizedOnly <- sapply(AllModelParameters, "[", "parameters")
 combinedParameters <- sapply(unstandardizedOnly, "[", "unstandardized")
 combinedParameters <- do.call("rbind", combinedParameters)
 
 combinedParameters$files<-substr(row.names(combinedParameters),6,62)


 results<-combinedParameters[,c("files", "paramHeader", "param","population",
                                "average", "average_se",  "population_sd","mse", "cover_95")]
 
 row.names(results)<-NULL
 results<-results[- which(results$population==1.000 & results$average_se==0.0000), ]
 results<-results[- which(results$population==0.000 & results$average_se==0.0000), ] 
 results <- unique(results)
 
 results$kind<-results$param
 
 pb1 <- tkProgressBar(title = "Progress", min = 0, max = dim(results)[1], width = 200) 
 for (e in 1:dim(results)[1]){
    Sys.sleep(0.001) 
    setTkProgressBar(pb1, e, label=paste(round(e/dim(results)[1]*100,1),"% done"))
    
    if(substr(results$paramHeader[e],5,6)=='WI' & substr(results$param[e],1,1)=='S')
    {results$kind[e] <- c('S covariance')} 
    else if(substr(results$paramHeader[e],4,5)=='WI' & substr(results$param[e],1,1)=='T')
    {results$kind[e] <- c('T covariance')} 
    else if(substr(results$paramHeader[e],4,5)=='WI' & substr(results$param[e],1,1)=='S')
    {results$kind[e] <- c('S covariance')} 
    else if (substr(results$paramHeader[e],1,3)=='Mea') 
    {results$kind[e] <- c('mean')}
    else if (substr(results$paramHeader[e],1,3)=='Var' & substr(results$param[e],1,1)=='S') 
    {results$kind[e] <- c('S variance')} 
    else if (substr(results$paramHeader[e],1,3)=='Var' & substr(results$param[e],1,1)=='T') 
    {results$kind[e] <- c('T variance')}
    else if (substr(results$paramHeader[e],1,3)=='Res') 
    {results$kind[e] <- c('residual')}
    else if (substr(results$paramHeader[e],1,3)=='Thr') 
    {results$kind[e] <- c('threshold')}
    else {results$kind[e] <- c('NE')}
 }
 close(pb1)
 results$kind <- as.factor(results$kind)
 
 #### Berechnung peb und seb
 results$peb<-round(abs(results$average-results$population)/abs(results$population),4)
 results$seb<-round(abs(results$average_se-results$population_sd)/abs(results$population_sd),4)
 results$bias<-round((results$average-results$population),4)
 results$abs_bias<-round(abs(results$average-results$population),4)
 results$abs_diff_sd_se<-round(abs(results$average_se-results$population_sd),4)
 results$diff_sd_se<-round((results$average_se-results$population_sd),4)
 results$ratio_sd_se<-round((results$average_se/results$population_sd),4)

 results$files <- recode(results$files, recodes='"LatentState_2constructs_N.40_parcel_T.9.out.parameters.un" = "Latent State 2 constructs T 9 free S var";
                         "LatentState_N.40_parcel_T.9_categ.5.out.parameters.unstan" = "Latent State T 9 free S var 5 categ";
                         "LatentState_N.40_parcel_T.9_categ.7.out.parameters.unstan" = "Latent State T 9 free S var 7 categ";
                         "LatentStateTrait_2constructs_N.40_parcel_T.9_fixed.out.pa" = "LST 2 constructs T 9 fixed";
                         "LatentStateTrait_2constructs_N.40_parcel_T.9_freeSvar.out" = "LST 2 constructs T 9 free S var";
                         "LatentStateTrait_N.40_parcel_T.12_defaultprior.out.parame" = "LST T 12 fixed S var";                         
                         "LatentStateTrait_N.40_parcel_T.12_freeSvar_defaultprior.o" = "LST T 12 free S var";
                         "LatentStateTrait_N.40_parcel_T.12_freeSvar_IG.out.paramet" = "LST T 12 free S var IG prior";
                         "LatentStateTrait_N.40_parcel_T.12_IG.out.parameters.unsta" = "LST fixed S var IG prior"')
 
 
 stats = ddply(
   .data = results 
   , .variables = .(results$files,results$kind)
   , .fun = function(x){ #apply this function to each combin. of the variables in .variables
     to_return = data.frame(
        peb = round(mean(x$peb),4)
       , seb = round(mean(x$seb),4)
       , mse = round(mean(x$mse),4)
       , cover_min = min(x$cover_95)
       , cover_max = max(x$cover_95)
       , cover_median = median(x$cover_95)
       , abs_bias = round(mean(x$abs_bias),4)
       , abs_diff_sd_se = round(mean(x$abs_diff_sd_se),4)
       
     )
     return(to_return)
   }
   , .progress = 'text'
 )

 names(stats) <- c("files","kind","peb","seb","mse","cover_min","cover_max","cover_median","abs_bias","abs_diff_sd_se")

 
 write.table(stats,file="Simulation_results_peb_seb.txt",sep="\t",row.names=FALSE)
 write.table(results,file="Simulation_results_long.txt",sep="\t",row.names=FALSE)

