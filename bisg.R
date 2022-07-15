library(checkpoint)
checkpoint("2022-01-01")

library(magrittr)
library(dplyr)
library(tidyr)
library(readr)
library(RODBC)
library(wru)
sessionInfo()


channel <- odbcDriverConnect("Driver=ODBC Driver 17 for SQL Server; Server=Wpohasqll17,5001\\SQLEXPRESS; Database=HAL_APAC; Uid=; Pwd=; trusted_connection=yes")
query <- read_file("discharges.sql")
df <- sqlQuery(channel, query)
odbcClose(channel)


predicted <-
  df %>%
  group_by(race) %>%
  sample_n(3) %>%
  ungroup() %>%
  arrange(race) %>%
  rename(surname = patient_last_name) %>%
  predict_race(surname.only = TRUE,
               surname.year = 2010) %>%
  select(-starts_with("geo"))

predicted %>% knitr::kable()
