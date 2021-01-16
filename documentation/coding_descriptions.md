# Coding description

## Data

* `date` (numeric): formatted in the following way: YYYYMMDD (e.g. 20180131)
* `time_point` (numeric): number of times the task is being administered, counted from the beginning of data collection
* `group` (text): group/species name
* `subject` (text): subject name
* `task` (text): which task is being tested, either "gaze_following"; "causality"; "inference"; "quantities"; "switching_place" or "switching_feature".
* `trial_time_point` (numeric): number of trial for this task within the time_point
* `code` (numeric): correct choice; for gaze_following, 1 is coded if the subject follows gaze and 0 if they do not

## Predictors

* `sick_severity` (numeric): 0 (not sick) to 7 (very sick) -- varies by **individual** & **test session**
* `test_day` (text): has the subject participated in a test on the same day (yes/no) -- varies by **individual** & **test session**
* `test_tp`	(numeric): how many tests did the subject participate in since the last time point -- varies by **individual** & **time point**
* `rank` (numeric): subject's rank in the group (scaled within group) -- varies by **individual** & **time point**
* `observer` (text): was and observer present at test -- varies by **individual** & **test session**
* `keeper` (text): name of the animal keeper -- varies by **group** & **test session**
* `age` (numeric): age of subject in years -- varies by **individual** & **test session**
* `in_leipzig` (numeric): time subject has lived in Leipzig in years -- varies by **individual** & **test session**
* `sex` (text): subject sex ("m" or "f")  -- varies by **individual**
* `rearing` (text): subjects rearing history ("mother", "hand", "unknown")  -- varies by **individual**
* `le_present` (text): did a noteworthy life event occur at that time point (e.g. death or birth of a group mate) -- varies by **group** & **time point**
* `le_mean` (numeric): mean severity of the life event - 0 (no life event) to 7 (very severe) -- varies by **group** & **time point**
* `le_max` (numeric): maximum severity of the life event - 0 (no life event) to 7 (very severe) -- varies by **group** & **time point**
* `dist_present` (text): was there any disturbance at that time point (e.g. noise due to construction work) -- varies by **group** & **time point**
* `dist_mean` (numeric): mean severity of the disturbance - 0 (no life event) to 7 (very severe) -- varies by **group** & **time point**
* `dist_max` (numeric): maximum severity of the disturbance - 0 (no life event) to 7 (very severe) -- varies by **group** & **time point**
* `time_outdoors` (numeric): average time spent outdoors at that time point (in hours)  -- varies by **group** & **time point**
