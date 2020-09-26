# Coding description

* date (numeric): formatted in the following way: YYYYMMDD (e.g. 20180131)
* time_point (numeric): number of times the task is being administered, counted from the beginning of data collection
* group	(text): group/species name
* subject (text): subject name
* sick_severity (numeric): 0 (not sick) to 7 (very sick)
* test_day (text): has the subject participated in a test on the same day (yes/no)
* test_tp	(numeric): how many tests did the subject participate in since the last time point
* rank (numeric): subject's rank in the group (scaled within group)
* task (text): which task is being tested, either "gaze_following"; "causality"; "inference"; "quantities"; "switching_place" or "switching_feature".
* trial_time_point (numeric): number of trial for this task within the time_point
* code (numeric): correct choice; for gaze_following, 1 is coded if the subject follows gaze and 0 if they do not