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
* Census surname statistics from 2010 (`surname.year = 2020`)
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
[1] maps_3.4.0       wru_1.0.0        RODBC_1.3-19     readr_2.1.2
[5] tidyr_1.2.0      dplyr_1.0.9      magrittr_2.0.3   checkpoint_1.0.2

loaded via a namespace (and not attached):
 [1] Rcpp_1.0.9        PL94171_1.0.2     pillar_1.7.0      compiler_4.1.2
 [5] tools_4.1.2       digest_0.6.29     jsonlite_1.8.0    memoise_2.0.1
 [9] lifecycle_1.0.1   tibble_3.1.7      pkgconfig_2.0.3   rlang_1.0.4
[13] cli_3.3.0         parallel_4.1.2    fastmap_1.1.0     furrr_0.3.0      
[17] stringr_1.4.0     generics_0.1.3    vctrs_0.4.1       globals_0.15.1
[21] hms_1.1.1         tidyselect_1.1.2  glue_1.6.2        listenv_0.8.0
[25] R6_2.5.1          fansi_1.0.3       parallelly_1.32.0 piggyback_0.1.4
[29] tzdb_0.3.0        purrr_0.3.4       codetools_0.2-18  ellipsis_0.3.2   
[33] future_1.26.1     utf8_1.2.2        stringi_1.7.6     cachem_1.0.6
[37] crayon_1.5.1     
```


## Results

The `age = TRUE`, `sex = TRUE`, `census.geo = "tract"`, and `census.geo = "block"` options return errors.
See Github [issue #71](https://github.com/kosukeimai/wru/issues/71#issuecomment-1190666049).

The scenario with the best agreement is **B**, county-level geocoding
(`census.geo = "county"`).

scenario | `surname.only` | `census.geo` | `age` | `sex` | $C$-statistic
---------|----------------|--------------|-------|-------|-----------
A        | TRUE           | NULL         | NULL  | NULL  | 0.45524
B        | FALSE          | county       | FALSE | FALSE | 0.87460
C        | FALSE          | county       | FALSE | TRUE  | NULL
D        | FALSE          | county       | TRUE  | FALSE | NULL
E        | FALSE          | county       | TRUE  | TRUE  | NULL
F        | FALSE          | tract        | FALSE | FALSE | NULL
G        | FALSE          | tract        | FALSE | TRUE  | NULL
H        | FALSE          | tract        | TRUE  | FALSE | NULL
I        | FALSE          | tract        | TRUE  | TRUE  | NULL
J        | FALSE          | block        | FALSE | FALSE | NULL
K        | FALSE          | block        | FALSE | TRUE  | NULL
L        | FALSE          | block        | TRUE  | FALSE | NULL
M        | FALSE          | block        | TRUE  | TRUE  | NULL

Predicted race and predicted race probability summary for scenario **A**.

|predicted              |  freq|      prop|      mean|       min|       p05|       p10|    median|       p90|       p95|       max|
|:----------------------|-----:|---------:|---------:|---------:|---------:|---------:|---------:|---------:|---------:|---------:|
|Asian/Pacific Islander |  1638| 0.0331881| 0.8233435| 0.2893776| 0.4758791| 0.5382613| 0.8999635| 0.9699724| 0.9753981| 1.0000000|
|Black                  |   170| 0.0034444| 0.6663070| 0.2652791| 0.3744455| 0.3934972| 0.6697424| 0.8820005| 0.9225654| 1.0000000|
|Hispanic/Latino        |  6537| 0.1324486| 0.8723317| 0.3345461| 0.6541630| 0.7480072| 0.8967314| 0.9638703| 0.9722831| 1.0000000|
|Other/Mixed            |    96| 0.0019451| 0.6314612| 0.3230183| 0.4272460| 0.4413181| 0.5664825| 0.9457234| 0.9725083| 0.9893271|
|White                  | 40914| 0.8289738| 0.8924912| 0.2898105| 0.6992367| 0.7372423| 0.9256092| 0.9693454| 0.9767259| 1.0000000|


## References

* `wru` R Package (https://github.com/kosukeimai/wru)
  * Imai, K. and Khanna, K. (2016) (https://imai.fas.harvard.edu/research/files/race.pdf and https://imai.fas.harvard.edu/research/files/race-supp.pdf)
* Imputation of Race and Ethnicity in Health Insurance Marketplace Enrollment Data, 2015 – 2022 Open Enrollment Periods(https://aspe.hhs.gov/reports/imputation-race-ethnicity-marketplace-enrollment-data)
* Voting Rights blog (https://rpvote.github.io/voting-rights/bisg/)
* RAND (https://www.rand.org/health-care/tools-methods/bisg.html)
* Is the accuracy of Bayesian Improved Surname Geocoding bad news for privacy protection at the Census? Technically no, PR-wise probably. (https://statmodeling.stat.columbia.edu/2021/10/27/is-the-accuracy-of-bayesian-improved-surname-geocoding-bad-news-for-privacy-protection-at-the-census-technically-no-pr-wise-probably/)

