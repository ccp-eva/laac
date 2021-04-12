# Baseline model

## Model

    performance ~                               # sum score for each time point
      sex + rearing + age + in_leipzig + rank +   
      sick_severity +                             
      le_mean + le_max + dist_mean +            # alternatively try xx_present or xx_max
      time_outdoors + 
      sociality +                               # alternative is sociality_total
      test_day + test_tp + observer +
      (1 | subject)
      
      # optional: heat; but different meaning for sexes

## Predictors

-   `sick_severity` (numeric): 0 (not sick) to 7 (very sick) -- varies by **individual** & **test session**
-   `heat` (text): for females: is the subject currently in heat (yes/no); for males: is there a female in the group that is currently in heat -- varies by **individual** & **time point**
-   `test_day` (text): has the subject participated in a test on the same day (yes/no) -- varies by **individual** & **test session**
-   `test_tp` (numeric): how many tests did the subject participate in since the last time point -- varies by **individual** & **time point**
-   `rank` (numeric): subject's rank in the group (scaled within group) -- varies by **individual** & **time point**
-   `observer` (text): was and observer present at test -- varies by **individual** & **test session** <!-- * `keeper` (text): name of the animal keeper -- varies by **group** & **test session** -->
-   `sex` (text): subject sex ("m" or "f") -- varies by **individual**
-   `rearing` (text): subjects rearing history ("mother", "hand", "unknown") -- varies by **individual**
-   `age` (numeric): age of subject in years -- varies by **individual** & **test session**
-   `in_leipzig` (numeric): time subject has lived in Leipzig in years -- varies by **individual** & **test session**
-   `le_present` (text): did a noteworthy life event occur at that time point (e.g. death or birth of a group mate) -- varies by **group** & **time point**
-   `le_mean` (numeric): mean severity of the life event - 0 (no life event) to 7 (very severe) -- varies by **group** & **time point**
-   `le_max` (numeric): maximum severity of the life event - 0 (no life event) to 7 (very severe) -- varies by **group** & **time point**
-   `dist_present` (text): was there any disturbance at that time point (e.g. noise due to construction work) -- varies by **group** & **time point**
-   `dist_mean` (numeric): mean severity of the disturbance - 0 (no life event) to 7 (very severe) -- varies by **group** & **time point**
-   `dist_max` (numeric): maximum severity of the disturbance - 0 (no life event) to 7 (very severe) -- varies by **group** & **time point**
-   `time_outdoors` (numeric): average time spent outdoors at that time point (in hours) -- varies by **group** & **time point**
-   `sociality` (numeric): sociality measure indicating how social the individual is in comparison to the rest of the group -- varies by **individual** & **time point**
-   `sociality_total` (numeric): aggregate sociality measure indicating how social the individual is in comparison to the rest of the group -- varies by **individual**
