library(tidyverse)
library(projpred)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Functions

create_summary <- function(cvarsel_sum, sol_terms) {
  
  sum_obj <- cvarsel_sum %>%
    tibble() %>%
    select(-!c(size, solution_terms, elpd.loo, rmse.loo, elpd.se, rmse.se)) %>% 
    pivot_longer(cols = c(elpd.loo, rmse.loo), values_to = "value", names_to = "stat") %>%
    pivot_longer(cols = c(elpd.se, rmse.se), values_to = "se", names_to = "se_term") %>%
    filter(str_detect(stat, "elpd") == str_detect(se_term, "elpd")) %>% 
    select(-se_term) %>%
    mutate(solution_terms = factor(ifelse(is.na(solution_terms), "none" ,solution_terms)),
           select = ifelse(solution_terms  %in% sol_terms, "yes", "no")) %>% 
    mutate(stat = case_when(stat == "elpd.loo" ~ "elpd",
                            TRUE ~ "rmse"))
  
  return(sum_obj)
  
}

ref_model_perf <- function(cvarsel_obj) {
  
  ref_perf <- tibble(
    stat = c('elpd', 'rmse'),
    value = c(sum(cvarsel_obj$summaries$ref$lppd) , 
              sqrt(mean((cvarsel_obj$refmodel$fit$data$cogn - cvarsel_obj$summaries$ref$mu)^2))))
  
  return(ref_perf)
  
}

summarise_prj <- function(prj_obj) {
  
  prj_out <- as.matrix(prj_obj) %>% 
    as_tibble() %>% 
    select(-contains(c("subject", "sigma"))) %>% 
    pivot_longer(cols = everything(), names_to = "pred", values_to = "value") %>% 
    mutate(factor = ifelse(grepl("group", pred), "group", "other predictors"),
           pred = str_remove(pred, "group"),
           pred = str_remove(pred, "rel_"),
           species = ifelse(factor == "group", pred, factor)) %>% 
    mutate(pred = str_replace(pred, pattern = "b_", replacement = ""))
  
  return(prj_out)
  
}

# Data Formatting

## Causality

### Phase 1

cvs_cau_p1 <- readRDS("cvs_cau_p1.rds")
cvs_cau_ref <- ref_model_perf(cvs_cau_p1)
saveRDS(cvs_cau_ref, "cvs_cau_ref.rds")

cvs_cau_summary <- summary(cvs_cau_p1, stat = c("elpd", "rmse"))$selection
cau_sol_terms <- c("(1 | subject)", "group")  # edit solution terms here
cvarselp <- create_summary(cvs_cau_summary, sol_terms = cau_sol_terms)
saveRDS(cvarselp, "cvs_cau_summary.rds")

proj_cau_cv <- project(cvs_cau_p1, solution_terms = cau_sol_terms)
proj_samples_cau <- summarise_prj(as.matrix(proj_cau_cv)) 
saveRDS(proj_samples_cau, "proj_cvs_cau.rds")

### Phase 2

cvs_cau_p2 <- readRDS("cvs_cau_p2.rds")
cvs_cau_ref_p2 <- ref_model_perf(cvs_cau_p2)
saveRDS(cvs_cau_ref_p2, "cvs_cau_ref_p2.rds")

cvs_cau_summary_p2 <- summary(cvs_cau_p2, stat = c("elpd", "rmse"))$selection
cau_sol_terms_p2 <- c("(1 | subject)", "group", "time_outdoors")  # edit solution terms here
cvarselp2 <- create_summary(cvs_cau_summary_p2, sol_terms = cau_sol_terms_p2)
saveRDS(cvarselp2, "cvs_cau_summary_p2.rds")

proj_cau_cv_p2 <- project(cvs_cau_p2,  solution_terms = cau_sol_terms_p2)
proj_samples_cau_p2 <- summarise_prj(as.matrix(proj_cau_cv_p2)) 
saveRDS(proj_samples_cau_p2, "proj_cvs_cau_p2.rds")

## Inference

### Phase 1

cvs_inf_p1 <- readRDS("cvs_inf_p1.rds")
cvs_inf_ref <- ref_model_perf(cvs_inf_p1)
saveRDS(cvs_inf_ref, "cvs_inf_ref.rds")

cvs_inf_summary <- summary(cvs_inf_p1, stat = c("elpd", "rmse"))$selection
inf_sol_terms <- c("(1 | subject)", "time_in_leipzig", "group", "age")  # edit solution terms here
ivarselp <- create_summary(cvs_inf_summary, sol_terms = inf_sol_terms)
saveRDS(ivarselp, "cvs_inf_summary.rds")

proj_inf_cv <- project(cvs_inf_p1,  solution_terms = inf_sol_terms)
proj_samples_inf <- summarise_prj(as.matrix(proj_inf_cv))
saveRDS(proj_samples_inf, "proj_cvs_inf.rds")

### Phase 2

cvs_inf_p2 <- readRDS("cvs_inf_p2.rds")
cvs_inf_ref_p2 <- ref_model_perf(cvs_inf_p2)
saveRDS(cvs_inf_ref_p2, "cvs_inf_ref_p2.rds")

cvs_inf_summary_p2 <- summary(cvs_inf_p2, stat = c("elpd", "rmse"))$selection
inf_sol_terms_p2 <- c("(1 | subject)", "group","time_in_leipzig","age")  # edit solution terms here
ivarselp2 <- create_summary(cvs_inf_summary_p2, sol_terms = inf_sol_terms_p2)
saveRDS(ivarselp2, "cvs_inf_summary_p2.rds")

proj_inf_cv_p2 <- project(cvs_inf_p2,  solution_terms = inf_sol_terms_p2)
proj_samples_inf_p2 <- summarise_prj(as.matrix(proj_inf_cv_p2))
saveRDS(proj_samples_inf_p2, "proj_cvs_inf_p2.rds")

## Quantity

### Phase 1

cvs_quant_p1 <- readRDS("cvs_quant_p1.rds")
cvs_quant_ref <- ref_model_perf(cvs_quant_p1)
saveRDS(cvs_quant_ref, "cvs_quant_ref.rds")

cvs_quant_summary <- summary(cvs_quant_p1, stat = c("elpd", "rmse"))$selection
quant_sol_terms <- c("(1 | subject)", "time_in_leipzig", "rearing", "group")  # edit solution terms here
qvarselp <- create_summary(cvs_quant_summary, sol_terms = quant_sol_terms)
saveRDS(qvarselp, "cvs_quant_summary.rds")

proj_quant_cv <- project(cvs_quant_p1,  solution_terms = quant_sol_terms)
proj_samples_quant <- summarise_prj(as.matrix(proj_quant_cv))
saveRDS(proj_samples_quant, "proj_cvs_quant.rds")

### Phase 2

cvs_quant_p2 <- readRDS("cvs_quant_p2.rds")
cvs_quant_ref_p2 <- ref_model_perf(cvs_quant_p2)
saveRDS(cvs_quant_ref_p2, "cvs_quant_ref_p2.rds")

cvs_quant_summary_p2 <- summary(cvs_quant_p2, stat = c("elpd", "rmse"))$selection
quant_sol_terms_p2 <- c("(1 | subject)", "rel_rank", "rearing", "time_in_leipzig", "group", "observer_mod", "time_outdoors")  # edit solution terms here
qvarselp2 <- create_summary(cvs_quant_summary_p2, sol_terms = quant_sol_terms_p2)
saveRDS(qvarselp2, "cvs_quant_summary_p2.rds")

proj_quant_cv_p2 <- project(cvs_quant_p2,  solution_terms = quant_sol_terms_p2)
proj_samples_quant_p2 <- summarise_prj(as.matrix(proj_quant_cv_p2))
saveRDS(proj_samples_quant_p2, "proj_cvs_quant_p2.rds")

## Gratification

### Phase 2

cvs_grat_p2 <- readRDS("cvs_grat_p2.rds")
cvs_grat_ref_p2 <- ref_model_perf(cvs_grat_p2)
saveRDS(cvs_grat_ref_p2, "cvs_grat_ref_p2.rds")

cvs_grat_summary_p2 <- summary(cvs_grat_p2, stat = c("elpd", "rmse"))$selection
grat_sol_terms_p2 <- c("(1 | subject)", "time_in_leipzig", "observer_mod", "sex", "rel_rank", "sick_severity")  # edit solution terms here
dgvarselp2 <- create_summary(cvs_grat_summary_p2, sol_terms = grat_sol_terms_p2)
saveRDS(dgvarselp2, "cvs_grat_summary_p2.rds")

proj_grat_cv_p2 <- project(cvs_grat_p2,  solution_terms = grat_sol_terms_p2)
proj_samples_grat_p2 <- summarise_prj(as.matrix(proj_grat_cv_p2))
saveRDS(proj_samples_grat_p2, "proj_cvs_grat_p2.rds")

# ## Gaze
# 
# ### Phase 1
# 
# cvs_gaze_p1 <- readRDS("cvs_gaze_p1.rds")
# cvs_gaze_ref <- ref_model_perf(cvs_gaze_p1)
# saveRDS(cvs_gaze_ref, "cvs_gaze_ref.rds")
# 
# cvs_gaze_summary <- summary(cvs_gaze_p1, stat = c("elpd", "rmse"))$selection
# gaze_sol_terms_p1 <- c("(1 | subject)", "group", "rearing", "time_outdoors", "age","sociality","sex","sick_severity", "observer_mod")  # edit solution terms here
# gvarselp <- create_summary(cvs_gaze_summary, sol_terms = gaze_sol_terms_p1)
# saveRDS(gvarselp, "cvs_gaze_summary.rds")
# 
# proj_gaze_cv <- project(cvs_gaze_p1,  solution_terms = gaze_sol_terms_p1)
# proj_samples_gaze <- summarise_prj(as.matrix(proj_gaze_cv))
# saveRDS(proj_samples_gaze, "proj_cvs_gaze.rds")
# 
# ### Phase 2
# 
# cvs_gaze_p2 <- readRDS("cvs_gaze_p2.rds")
# cvs_gaze_ref_p2 <- ref_model_perf(cvs_gaze_p2)
# saveRDS(cvs_gaze_ref_p2, "cvs_gaze_ref_p2.rds")
# 
# cvs_gaze_summary_p2 <- summary(cvs_gaze_p2, stat = c("elpd", "rmse"))$selection
# gaze_sol_terms_p2 <- c("(1 | subject)", "group", "sex", "observer_mod", "age")  # edit solution terms here
# gvarselp2 <- create_summary(cvs_gaze_summary_p2, sol_terms = gaze_sol_terms_p2)
# saveRDS(gvarselp2, "cvs_gaze_summary_p2.rds")
# 
# proj_gaze_cv_p2 <- project(cvs_gaze_p2,  solution_terms = gaze_sol_terms_p2)
# proj_samples_gaze_p2 <- summarise_prj(as.matrix(proj_gaze_cv_p2))
# saveRDS(proj_samples_gaze_p2, "proj_cvs_gaze_p2.rds")

