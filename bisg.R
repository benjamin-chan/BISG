library(checkpoint)
checkpoint("2022-01-01")

library(magrittr)
library(dplyr)
library(tidyr)
library(readr)
library(RODBC)
library(wru)
library(maps)
data(state.fips)
sessionInfo()


channel <-
  c("Driver=ODBC Driver 17 for SQL Server",
    "Server=Wpohasqll17,5001\\SQLEXPRESS",
    "Database=HAL_APAC",
    "Uid=",
    "Pwd=",
    "trusted_connection=yes") %>%
  paste(collapse = "; ") %>%
  odbcDriverConnect()
query <- read_file("discharges.sql")
df <- sqlQuery(channel, query)
odbcClose(channel)


key <- read_file("C:/Users/or0250652/OneDrive - Oregon DHSOHA/API keys/censusAPIKey.txt")


predicted <-
  df %>%
  rename(surname = patient_last_name) %>%
  inner_join(state.fips %>% select(fips, abb) %>% unique(),
             by = c("geo_state_fips" = "fips")) %>%
  rename(state = abb) %>%
  mutate(county = sprintf("%03d", geo_county_fips),
         tract = sprintf("%06d", geo_census_tract),
         block = sprintf("%04d", geo_census_block)) %>%
  mutate(sex = case_when(gender == "M" ~ 0,
                         gender == "F" ~ 1)) %>%
  select(-c(gender,
            geo_census_id,
            geo_state_fips,
            geo_county_fips,
            geo_census_tract,
            geo_census_block)) %>%
  predict_race(surname.only = FALSE,
               surname.year = 2010,
               census.geo = "county",
               census.key = key,
               age = TRUE,
               sex = TRUE)

predicted %>% knitr::kable()
