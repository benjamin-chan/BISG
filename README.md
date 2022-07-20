# Bayesian Improved Surname Geocoding (BISG) on Hospital Discharge Data (Proof-of-concept)

Carry out a proof-of-concept experiment of Bayesian Improved Surname Geocoding
(BISG) on Hospital Discharge Data.
The R package [`wru`](https://github.com/kosukeimai/wru) is used.

Required inputs are patient's last name and geocoded residential address.
Optional inputs are patient's age and sex.


## Experimental conditions

* Inclusion criteria
  * 2019-2021 discharge date
  * Oregon residence (`state == "OR"`)
  * Address-level geocoding (`geo_result_category == "A"`)
  * Non-missing age (`!is.na(age)`)
  * Non-missing sex (`!is.na(sex)`)
* Census surname statistics from 2010 (`surname.year = 2010`)
* Agreement is defined as
  * Ethnicity on discharge is not Hispanic or Latino and race on discharge matches predicted race, or
  * Ethnicity on discharge is Hispanic or Latino and predicted race is Hispanic/Latino

R code is in `bisg.R`.

```
> dim(df)
[1] 840468     11
```

```
> sessionInfo()
R version 4.1.2 (2021-11-01)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows 10 x64 (build 19042)

Matrix products: default

locale:
[1] LC_COLLATE=English_United States.1252
[2] LC_CTYPE=English_United States.1252   
[3] LC_MONETARY=English_United States.1252
[4] LC_NUMERIC=C
[5] LC_TIME=English_United States.1252    

attached base packages:
[1] stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
[1] maps_3.4.0       wru_0.1-12       RODBC_1.3-19     readr_2.1.1
[5] tidyr_1.1.4      dplyr_1.0.7      magrittr_2.0.1   checkpoint_1.0.2

loaded via a namespace (and not attached):
 [1] pillar_1.6.4      compiler_4.1.2    prettyunits_1.1.1 remotes_2.4.2
 [5] tools_4.1.2       testthat_3.1.1    pkgbuild_1.3.1    pkgload_1.2.4    
 [9] jsonlite_1.8.0    memoise_2.0.1     lifecycle_1.0.1   tibble_3.1.6
[13] pkgconfig_2.0.3   rlang_1.0.4       cli_3.3.0         fastmap_1.1.0    
[17] withr_2.4.3       generics_0.1.1    desc_1.4.0        fs_1.5.2
[21] vctrs_0.3.8       devtools_2.4.3    hms_1.1.1         rprojroot_2.0.2  
[25] tidyselect_1.1.1  glue_1.6.0        R6_2.5.1          processx_3.5.2
[29] fansi_0.5.0       sessioninfo_1.2.2 tzdb_0.2.0        purrr_0.3.4      
[33] callr_3.7.0       usethis_2.1.5     ps_1.6.0          ellipsis_0.3.2   
[37] utf8_1.2.2        cachem_1.0.6      crayon_1.4.2
```


## Results

The scenario with the best agreement is surname-only prediction with no
geocoding (`surname.only = TRUE`).

`surname.only` | `census.geo` | `age` | `sex` | $C$-statistic
---------------|--------------|-------|-------|-----------
TRUE           | NULL         | NULL  | NULL  | 0.86465
FALSE          | county       | FALSE | FALSE | 0.85537
FALSE          | county       | FALSE | TRUE  | 0.85575
FALSE          | county       | TRUE  | FALSE | 0.86101
FALSE          | county       | TRUE  | TRUE  | 0.86098
FALSE          | tract        | FALSE | FALSE | 0.85848
FALSE          | tract        | FALSE | TRUE  | 0.85863
FALSE          | tract        | TRUE  | FALSE | 0.86284
FALSE          | tract        | TRUE  | TRUE  | 0.86047
FALSE          | block        | FALSE | FALSE | 0.85035
FALSE          | block        | FALSE | TRUE  | 0.84774
FALSE          | block        | TRUE  | FALSE | 0.82433
FALSE          | block        | TRUE  | TRUE  | 0.81743


## References

* `wru` R Package (https://github.com/kosukeimai/wru)
  * Imai, K. and Khanna, K. (2016) (https://imai.fas.harvard.edu/research/files/race.pdf and https://imai.fas.harvard.edu/research/files/race-supp.pdf)
* Imputation of Race and Ethnicity in Health Insurance Marketplace Enrollment Data, 2015 – 2022 Open Enrollment Periods(https://aspe.hhs.gov/reports/imputation-race-ethnicity-marketplace-enrollment-data)
* Voting Rights blog (https://rpvote.github.io/voting-rights/bisg/)
* RAND (https://www.rand.org/health-care/tools-methods/bisg.html)

