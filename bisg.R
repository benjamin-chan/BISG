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
discharges <- sqlQuery(channel, query)
odbcClose(channel)


df <-
  discharges %>%
  rename(surname = patient_last_name) %>%
  inner_join(state.fips %>% select(fips, abb) %>% unique(),
             by = c("geo_state_fips" = "fips")) %>%
  rename(state = abb) %>%
  mutate(county = sprintf("%03d", geo_county_fips),
         tract = sprintf("%06d", geo_census_tract),
         block = sprintf("%04d", geo_census_block)) %>%
  mutate(sex = case_when(gender == "M" ~ 0,
                         gender == "F" ~ 1)) %>%
  mutate(race = case_when(race == "R1" ~ "American Indian or Alaska Native",
                          race == "R2" ~ "Asian",
                          race == "R3" ~ "Black or African American",
                          race == "R4" ~ "Native Hawaiian or Pacific Islander",
                          race == "R5" ~ "White",
                          race == "R7" ~ "Patient Refused",
                          race == "R8" ~ "Unknown",
                          race == "R9" ~ "Other")) %>%
  mutate(ethnicity = case_when(ethnicity == "E1" ~ "Hispanic or Latino",
                               ethnicity == "E2" ~ "Non-Hispanic or Latino",
                               ethnicity == "E8" ~ "Patient Refused",
                               ethnicity == "E9" ~ "Unknown")) %>%
  select(-c(gender,
            geo_census_id,
            geo_state_fips,
            geo_county_fips,
            geo_census_tract,
            geo_census_block)) %>%
  filter(state == "OR") %>%
  filter(geo_result_category == "A") %>%
  filter(!is.na(age) & !is.na(sex))
dim(df)
  
  
key <- read_file("C:/Users/or0250652/OneDrive - Oregon DHSOHA/API keys/censusAPIKey.txt")
probabilities <-
  df %>%
  predict_race(surname.only = FALSE,
               surname.year = 2010,
               census.geo = "county",
               census.key = key,
               age = FALSE,
               sex = FALSE)
               

predicted %>%
  pivot_longer(starts_with("pred."), names_to = "predicted", values_to = "probability") %>%
  group_by(record_id) %>%
  arrange(-probability) %>%
  filter(row_number() == 1) %>%
  ungroup() %>%
  mutate(predicted = case_when(predicted == "pred.whi" ~ "White",
                               predicted == "pred.bla" ~ "Black",
                               predicted == "pred.his" ~ "Hispanic/Latino",
                               predicted == "pred.asi" ~ "Asian/Pacific Islander",
                               predicted == "pred.oth" ~ "Other/Mixed")) %>%
  mutate(agreement = (ethnicity != "Hispanic or Latino" & race == predicted) |
                     (ethnicity == "Hispanic or Latino" & predicted == "Hispanic or Latino"))


cstatistic <-
  predicted %>%
  filter(!(race %in% c("Patient Refused", "Unknown", "Other") &
         !(ethnicity %in% c("Patient Refused", "Unknown")))) %>%
  summarize(cstatistic = sum(agreement) / n()) %>%
  pull(cstatistic)
cstatistic %>% sprintf("C-statistic: %.5f", .) %>% message()
