# library(checkpoint)
# checkpoint("2022-07-20")

library(magrittr)
library(dplyr)
library(tidyr)
library(readr)
library(RODBC)
# remotes::install_github("kosukeimai/wru", ref = "issue_72")
library(wru)
key <- read_file("C:/Users/or0250652/OneDrive - Oregon DHSOHA/API keys/censusAPIKey.txt")
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
  filter(geo_state_fips == 41) %>%
  filter(geo_result_category == "A") %>%
  filter(!is.na(age) & gender %in% c("F", "M")) %>%
  filter(!(geo_county_fips == 023 & geo_census_tract == 970300 |
           geo_county_fips == 049 & geo_census_tract == 000300)) %>%
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
            geo_census_block))
dim(df)


probabilities <-
  df %>%
  predict_race(surname.only = FALSE,
               surname.year = 2020,
               census.geo = "tract",
               census.key = key,
               age = FALSE,
               sex = FALSE)


predicted <-
  probabilities %>%
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
  mutate(agreement = (ethnicity != "Hispanic or Latino" & predicted == "White" & race == "White") |
                     (ethnicity != "Hispanic or Latino" & predicted == "Black" & race == "Black or African American") |
                     (ethnicity == "Hispanic or Latino" & predicted == "Hispanic/Latino") |
                     (ethnicity != "Hispanic or Latino" & predicted == "Asian/Pacific Islander" & race %in% c("Asian", "Native Hawaiian or Pacific Islander")) |
                     (ethnicity != "Hispanic or Latino" & predicted == "Other/Mixed" & race %in% c("American Indian or Alaska Native", "Other")))


cstatistic <-
  predicted %>%
  filter(!(race %in% c("Patient Refused", "Unknown")) |
         ethnicity == "Hispanic or Latino") %>%
  summarize(cstatistic = sum(agreement) / n()) %>%
  pull(cstatistic)
cstatistic %>% sprintf("C-statistic: %.5f", .) %>% message()


predicted %>%
  filter(race %in% c("Patient Refused", "Unknown") &
         ethnicity != "Hispanic or Latino") %>%
  group_by(predicted) %>%
  summarize(freq = n(),
            prop = NA,
            mean = mean(probability),
            min = min(probability),
            p05 = quantile(probability, p = 0.05),
            p10 = quantile(probability, p = 0.10),
            median = median(probability),
            p90 = quantile(probability, p = 0.90),
            p95 = quantile(probability, p = 0.95),
            max = max(probability)) %>%
  ungroup() %>%
  mutate(prop = freq / sum(freq)) %>%
  knitr::kable()
