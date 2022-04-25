# Data pre-processing -----------------------------------------------------
# Packages & Options
library(tidyverse)
library(brms)
library(projpred)

# Parallelization
# library(doParallel)
# ncores <- parallel::detectCores()
# doParallel::registerDoParallel(cl = ncores)
# trigger_default <- options(projpred.prll_prj_trigger = 200)
# options(mc.cores = ncores)

# Data
url <- RCurl::getURL("https://raw.githubusercontent.com/ccp-eva/laac/master/data/laac_data_trial.csv")
df_trials <- read_csv(url)

# remove variables not relevant to PPI analysis
df_trials <- df_trials %>% 
  select(-c(time_waited, birth_date, comment, experimenter, pick, condition, heat))

# data pre-processing

sum_resp <- function(x, ...) {
  # helper function: sum over `correct response` variable (code)
  to_return = tibble(cogn = sum(x$code))
}

resp_sum <- df_trials %>%
  # contains summed code variable for [task, time point, session, subject]
  group_by(time_point, session, subject, task) %>%
  group_modify(sum_resp)

df_tmp <- df_trials %>%
  # helper for merging
  select(-c(date, trial_session, trial_time_point, code)) %>%
  unique(by = c("time_point", "session", "subject"))

df_trials_final <- inner_join(df_tmp, resp_sum)

df_trials_final <- df_trials_final %>% 
  # grand mean center below variables
  mutate(across(c(sick_severity, 
                  le_mean, 
                  dist_mean, 
                  time_outdoors, 
                  age, 
                  time_in_leipzig), 
                ~scale(., center = T, scale = F))) %>% 
  mutate(across(c(session, 
                  subject, 
                  group, 
                  sex,
                  test_day, 
                  le_present, 
                  dist_present,
                  rearing,
                  observer), 
                as_factor)) %>% 
  mutate(observer = fct_relevel(observer, "no")) %>% 
  mutate(rearing = fct_recode(rearing, "hand" = "unknown")) %>% 
  # create new observer variable due to different measurements of observer between phases
  mutate(observer_mod = case_when(
    observer == "yes" ~ "yes",
    observer == "no" ~ "no",
    observer != "no" & observer != "yes" & observer != "NA" ~ "yes",
    TRUE ~ "no"
  ), observer_mod =  as_factor(observer_mod))

grp_size <- tibble(
  # number of apes for each species
  a_chimp = 20,
  b_chimp = 6,
  bonobo = 12,
  gorilla = 6,
  orangutan = 6
)

df_trials_final <- df_trials_final %>%
  # relative rank of ape within species (varies between time points)
  group_by(group, time_point) %>%
  mutate(
    rel_rank = case_when(
      group == "a_chimp" ~ percent_rank(grp_size$a_chimp:1)[rank],
      group == "b_chimp" ~ percent_rank(grp_size$b_chimp:1)[rank],
      group == "bonobo" ~ percent_rank(grp_size$bonobo:1)[rank],
      group == "gorilla" ~ percent_rank(grp_size$gorilla:1)[rank],
      group == "orangutan" ~ percent_rank(grp_size$orangutan:1)[rank]
    )
  ) %>%
  ungroup()

# create complete subsets for each task
t_cau <- filter(df_trials_final, task == "causality")
t_inf <- filter(df_trials_final, task == "inference")
t_quant <- filter(df_trials_final, task == "quantity")
t_gaze <- filter(df_trials_final, task == "gaze_following")
t_grat <- filter(df_trials_final, task == "delay_of_gratification")

t_gaze <- t_gaze %>%
  # create dummy variable indicating if in session 1 or 2
  group_by(time_point, session) %>% 
  mutate(tp_mod = cur_group_id()) %>%
  ungroup() %>% 
  mutate(day2 = case_when(session == 1 ~ "no",
                          session == 2 ~ "yes"),
         day2 = factor(day2)) %>%
  select(tp_mod, day2, everything())

t_gaze <- t_gaze %>%
  # remove duplicates created by day2
  group_by(subject) %>%
  filter(!duplicated(tp_mod)) %>%   
  ungroup() 

# filter data to only include time points from phase 1
t_cau_p1 <- filter(t_cau, time_point < 15)
t_inf_p1 <- filter(t_inf, time_point < 15)
t_quant_p1 <- filter(t_quant, time_point < 15)
t_gaze_p1 <- filter(t_gaze, time_point < 15)

# filter data to only include time points from phase 2
t_cau_p2 <- filter(t_cau, time_point >= 15)
t_inf_p2 <- filter(t_inf, time_point >= 15)
t_quant_p2 <- filter(t_quant, time_point >= 15)
t_gaze_p2 <- filter(t_gaze, time_point >= 15)
t_grat_p2 <- filter(t_grat, time_point >= 15)

# Covariate selection

# formula for reference models
fm <- formula(cogn ~ sick_severity +                    
                test_tp + test_day +             
                rel_rank + 
                observer_mod + 
                age + time_in_leipzig +
                sex + group +
                rearing +
                le_mean + dist_mean + 
                time_outdoors +
                sociality +
                (1|subject))
# formula for gaze reference model
fm_gaze <- formula(cogn ~ sick_severity +                    
                     test_tp + test_day + time_point + day2 +            
                     rel_rank + 
                     observer_mod + 
                     age + time_in_leipzig +
                     sex + group +
                     rearing +
                     le_mean + dist_mean + 
                     time_outdoors +
                     sociality +
                     (1 + time_point|subject))


## Reference Model: 2-level Multilevel Model
m_cau_2l_p1 <- brm(fm, data = t_cau_p1, 
                   warmup = 1e3, iter = 4e3, cores = parallel::detectCores(), chains = 4, 
                   seed = 2021)
m_inf_2l_p1 <- brm(fm, data = t_inf_p1, 
                   warmup = 1e3, iter = 4e3, cores = parallel::detectCores(), chains = 4, 
                   seed = 2021)
m_quant_2l_p1 <- brm(fm, data = t_quant_p1, 
                     warmup = 1e3, iter = 4e3, cores = parallel::detectCores(), chains = 4, 
                     seed = 2021)
m_gaze_2l_p1 <- brm(fm_gaze, data = t_gaze_p1, 
                    warmup = 1e3, iter = 4e3, cores = parallel::detectCores(), chains = 4, 
                    seed = 2021)

m_cau_2l_p2 <- brm(fm, data = t_cau_p2, 
                   warmup = 1e3, iter = 4e3, cores = parallel::detectCores(), chains = 4, 
                   seed = 2022)
m_inf_2l_p2 <- brm(fm, data = t_inf_p2, 
                   warmup = 1e3, iter = 4e3, cores = parallel::detectCores(), chains = 4, 
                   seed = 2022)
m_quant_2l_p2 <- brm(fm, data = t_quant_p2, 
                     warmup = 1e3, iter = 4e3, cores = parallel::detectCores(), chains = 4, 
                     seed = 2022)
m_gaze_2l_p2 <- brm(fm_gaze, data = t_gaze_p2, 
                    warmup = 1e3, iter = 4e3, cores = parallel::detectCores(), chains = 4, 
                    seed = 2022)
m_grat_2l_p2 <- brm(fm, data = t_grat_p2,
                    warmup = 1e3, iter = 4e3, cores = parallel::detectCores(), chains = 4, 
                    seed = 2022)



# summary(m_cau_2l_p1)
# summary(m_inf_2l_p1)
# summary(m_quant_2l_p1)
# summary(m_gaze_2l_p1)
# 
# summary(m_cau_2l_p2)
# summary(m_inf_2l_p2)
# summary(m_quant_2l_p2)
# summary(m_gaze_2l_p2)
# summary(m_grat_2l_p2)

# loo_p1 <- lapply(list(m_cau_2l_p1, m_inf_2l_p1, m_quant_2l_p1, m_gaze_2l_p1), loo::loo)
# loo_p2 <- lapply(list(m_cau_2l_p2, m_inf_2l_p2, m_quant_2l_p2, m_gaze_2l_p2, m_grat_2l_p2), loo::loo)

## Projection Prediction Inference

all_fixed_effects <- c("sick_severity",
                       "test_tp", "test_day",
                       "rel_rank",
                       "observer_mod",
                       "age", "time_in_leipzig",
                       "sex", "group",
                       "rearing",
                       "le_mean", "dist_mean",
                       "time_outdoors",
                       "sociality")
# delay random intercept to last place so that it doesn't soak up all the variance
s_terms <- c("1", all_fixed_effects, 
             paste0(paste(all_fixed_effects, collapse = " + "), 
                    " + (1 | subject)")) 
# gaze task gets its own search terms vector (including day2 and time_point (fixed/random))
s_terms_gaze <- c("1", c(all_fixed_effects, "day2", "time_point"), 
                  paste0(paste(all_fixed_effects, collapse = " + "), 
                         " + (1 | subject)"),
                  paste0(paste(all_fixed_effects, collapse = " + "), 
                         " + (time_point | subject)"))


## Phase 1
tmp <- Sys.time()

cvs_cau_p1 <- cv_varsel(m_cau_2l_p1, 
                        search_terms = s_terms, 
                        cv_method = "LOO", method = "forward",
                        seed = 2020)
sum_cau_p1 <- summary(cvs_cau_p1)
p <- plot(cvs_cau_p1, stats = c("elpd", "rmse"), deltas = TRUE)
ggsave(p, file = "cvs_cau_p1.pdf")
saveRDS(sum_cau_p1, file = "sum_cau_p1.rds")

cvs_inf_p1 <- cv_varsel(m_inf_2l_p1, 
                        search_terms = s_terms, 
                        cv_method = "LOO", method = "forward",
                        seed = 2020)
sum_inf_p1 <- summary(cvs_inf_p1)
p <- plot(cvs_inf_p1, stats = c("elpd", "rmse"), deltas = TRUE)
ggsave(p, file = "cvs_inf_p1.pdf")
saveRDS(sum_inf_p1, file = "sum_inf_p1.rds")

cvs_quant_p1 <- cv_varsel(m_quant_2l_p1, 
                          search_terms = s_terms, 
                          cv_method = "LOO", method = "forward", 
                          seed = 2020)
sum_quant_p1 <- summary(cvs_quant_p1)
p <- plot(cvs_quant_p1, stats = c("elpd", "rmse"), deltas = TRUE)
ggsave(p, file = "cvs_quant_p1.pdf")
saveRDS(sum_quant_p1, file = "sum_quant_p1.rds")

cvs_gaze_p1 <- cv_varsel(m_gaze_2l_p1, 
                         search_terms = s_terms_gaze, 
                         cv_method = "LOO", method = "forward", 
                         seed = 2020)
sum_gaze_p1 <- summary(cvs_gaze_p1)
p <- plot(cvs_gaze_p1, stats = c("elpd", "rmse"), deltas = TRUE)
ggsave(p, file = "cvs_gaze_p1.pdf")
saveRDS(sum_gaze_p1, file = "sum_gaze_p1.rds")

## Phase 2
cvs_cau_p2 <- cv_varsel(m_cau_2l_p2, 
                        search_terms = s_terms, 
                        cv_method = "LOO", method = "forward", 
                        seed = 2022)
sum_cau_p2 <- summary(cvs_cau_p2)
p <- plot(cvs_cau_p2, stats = c("elpd", "rmse"), deltas = TRUE)
ggsave(p, file = "cvs_cau_p2.pdf")
saveRDS(sum_cau_p2, file = "cvs_cau_p2.rds")

cvs_inf_p2 <- cv_varsel(m_inf_2l_p2, 
                        search_terms = s_terms, 
                        cv_method = "LOO", method = "forward", 
                        seed = 2022)
sum_inf_p2 <- summary(cvs_inf_p2)
p <- plot(cvs_inf_p2, stats = c("elpd", "rmse"), deltas = TRUE)
ggsave(p, file = "cvs_inf_p2.pdf")
saveRDS(sum_inf_p2, file = "sum_inf_p2.rds")

cvs_quant_p2 <- cv_varsel(m_quant_2l_p2, 
                          search_terms = s_terms, 
                          cv_method = "LOO", method = "forward", 
                          seed = 2022)
sum_quant_p2 <- summary(cvs_quant_p2)
p <- plot(cvs_quant_p2, stats = c("elpd", "rmse"), deltas = TRUE)
ggsave(p, file = "cvs_quant_p2.pdf")
saveRDS(sum_quant_p2, file = "cvs_quant_p2.rds")

cvs_gaze_p2 <- cv_varsel(m_gaze_2l_p2, 
                         search_terms = s_terms_gaze, 
                         cv_method = "LOO", method = "forward", 
                         seed = 2022)
sum_gaze_p2 <- summary(cvs_gaze_p2)
p <- plot(cvs_gaze_p2, stats = c("elpd", "rmse"), deltas = TRUE)
ggsave(p, file = "cvs_gaze_p2.pdf")
saveRDS(sum_gaze_p2, file = "cvs_gaze_p2.rds")

cvs_grat_p2 <- cv_varsel(m_grat_2l_p2, 
                         search_terms = s_terms, 
                         cv_method = "LOO", method = "forward", 
                         seed = 2022)
sum_grat_p2 <- summary(cvs_grat_p2)
p <- plot(cvs_grat_p2, stats = c("elpd", "rmse"), deltas = TRUE)
ggsave(p, file = "cvs_grat_p2.pdf")
saveRDS(sum_grat_p2, file = "sum_grat_p2.rds")

simtime <- Sys.time() - tmp  # information on duration
sesinfo <- sessionInfo()     # information on session

