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
  * Valid census tract
* Census surname statistics from 2010 (`surname.year = 2020`)
* Agreement is defined as
  * Ethnicity on discharge is not Hispanic or Latino and race on discharge matches predicted race, or
  * Ethnicity on discharge is Hispanic or Latino and predicted race is Hispanic/Latino

R code is in `bisg.R`.

```
> dim(df)
[1] 840460     11
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
[1] maps_3.4.0     wru_1.0.0010   RODBC_1.3-19   readr_2.1.2    tidyr_1.2.0   
[6] dplyr_1.0.9    magrittr_2.0.3

loaded via a namespace (and not attached):
 [1] Rcpp_1.0.9        PL94171_1.0.2     pillar_1.8.0      compiler_4.1.2
 [5] tools_4.1.2       digest_0.6.29     jsonlite_1.8.0    memoise_2.0.1    
 [9] lifecycle_1.0.1   tibble_3.1.8      pkgconfig_2.0.3   rlang_1.0.4
[13] cli_3.3.0         parallel_4.1.2    fastmap_1.1.0     furrr_0.3.0      
[17] stringr_1.4.0     generics_0.1.3    vctrs_0.4.1       globals_0.15.1
[21] hms_1.1.1         tidyselect_1.1.2  glue_1.6.2        listenv_0.8.0    
[25] R6_2.5.1          fansi_1.0.3       parallelly_1.32.1 piggyback_0.1.4
[29] tzdb_0.3.0        purrr_0.3.4       codetools_0.2-18  ellipsis_0.3.2   
[33] future_1.27.0     utf8_1.2.2        stringi_1.7.8     cachem_1.0.6
```


## Results

The scenario with the best agreement is **F**, tract-level geocoding
(`census.geo = "tract"`).

Current version of `wru` does not support age, sex conditioning.
See https://github.com/kosukeimai/wru/issues/71#issuecomment-1190666049.

scenario | `surname.only` | `census.geo` | `age` | `sex` | $C$-statistic
---------|----------------|--------------|-------|-------|-----------
A        | TRUE           | NULL         | NULL  | NULL  | 0.86332
B        | FALSE          | county       | FALSE | FALSE | 0.87460
C        | FALSE          | county       | FALSE | TRUE  | NULL
D        | FALSE          | county       | TRUE  | FALSE | NULL
E        | FALSE          | county       | TRUE  | TRUE  | NULL
F        | FALSE          | tract        | FALSE | FALSE | 0.87619
G        | FALSE          | tract        | FALSE | TRUE  | NULL
H        | FALSE          | tract        | TRUE  | FALSE | NULL
I        | FALSE          | tract        | TRUE  | TRUE  | NULL
J        | FALSE          | block        | FALSE | FALSE | 0.87188
K        | FALSE          | block        | FALSE | TRUE  | NULL
L        | FALSE          | block        | TRUE  | FALSE | NULL
M        | FALSE          | block        | TRUE  | TRUE  | NULL

Predicted race and predicted race probability summary for scenario **F** for
individuals with *refused* or *unknown* race and not *Hispanic or Latino*
ethnicity.

|predicted              |  freq|      prop|      mean|       min|       p05|       p10|    median|       p90|       p95|      max|
|:----------------------|-----:|---------:|---------:|---------:|---------:|---------:|---------:|---------:|---------:|--------:|
|Asian/Pacific Islander |  1630| 0.0330260| 0.8369279| 0.2918976| 0.4897756| 0.5584500| 0.9135085| 0.9841469| 0.9878710| 1.000000|
|Black                  |   283| 0.0057340| 0.6261547| 0.2932883| 0.3776828| 0.4252967| 0.5938938| 0.9059579| 0.9298845| 1.000000|
|Hispanic/Latino        |  6639| 0.1345152| 0.8688391| 0.3003855| 0.5834381| 0.6888065| 0.9103905| 0.9804194| 0.9877477| 1.000000|
|Other/Mixed            |   111| 0.0022490| 0.6335087| 0.3555446| 0.4132432| 0.4491758| 0.5721511| 0.9235163| 0.9699468| 0.990325|
|White                  | 40692| 0.8244757| 0.8925695| 0.2619293| 0.6490564| 0.7582839| 0.9296052| 0.9738844| 0.9808479| 1.000000|


## References

* `wru` R Package (https://github.com/kosukeimai/wru)
  * Imai, K. and Khanna, K. (2016) (https://imai.fas.harvard.edu/research/files/race.pdf and https://imai.fas.harvard.edu/research/files/race-supp.pdf)
* Imputation of Race and Ethnicity in Health Insurance Marketplace Enrollment Data, 2015 – 2022 Open Enrollment Periods(https://aspe.hhs.gov/reports/imputation-race-ethnicity-marketplace-enrollment-data)
* Voting Rights blog (https://rpvote.github.io/voting-rights/bisg/)
* RAND (https://www.rand.org/health-care/tools-methods/bisg.html)
* Is the accuracy of Bayesian Improved Surname Geocoding bad news for privacy protection at the Census? Technically no, PR-wise probably. (https://statmodeling.stat.columbia.edu/2021/10/27/is-the-accuracy-of-bayesian-improved-surname-geocoding-bad-news-for-privacy-protection-at-the-census-technically-no-pr-wise-probably/)

