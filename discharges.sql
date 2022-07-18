select A.patient_last_name,
       B.geo_census_id,
       B.geo_state_fips,
       B.geo_county_fips,
       B.geo_census_tract,
       B.geo_census_block,
       B.geo_result_category,
       A.race,
       A.ethnicity,
       A.age,
       A.gender,
       A.record_id
from hosp.hdd A inner join
     hosp.hdd_geocode B on A.record_id = B.record_id
where year(A.discharge_date) = 2021
;