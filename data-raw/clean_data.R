library(tidyverse)
library(googleCloudStorageR)
library(dplyr)
library(magrittr)

# google cloud set up
# gcs_auth(json_file = Sys.getenv("GCS_AUTH_FILE"))
# gcs_global_bucket(bucket = Sys.getenv("GCS_DEFAULT_BUCKET"))
# 
# # get data from google cloud
# gcs_get_object(object_name = "juvenile-rearing-monitoring/seine-and-snorkel-data/feather-river/data/combined_feather_snorkel_data.csv",
#                bucket = gcs_get_global_bucket(),
#                saveToDisk =  here::here("data-raw", ""),
               # overwrite = TRUE)

microhabitat_fish_observations <- read_csv(here::here("data", "microhabitat_with_fish_observations.csv")) |> 
  glimpse()

survey_locations <- read_csv(here::here("data", "survey_locations.csv")) |> 
  glimpse()

# clean data --------------------------------------------------------------
# here is where we clean up the data and make sure it all looks as expected
# check unique values for each column
# check that all fields are being read in the right way

survey_locations <- survey_locations |> 
  mutate(weather = tolower(weather), #changing categorical variables to lowercase
         channel_type = tolower(channel_type)) |> 
  glimpse()

summary(microhabitat_fish_observations)
table(microhabitat_fish_observations$species)
table(microhabitat_fish_observations$channel_geomorphic_unit)

summary(survey_locations)
table(survey_locations$location)
table(survey_locations$weather)
table(survey_locations$channel_type)
table(survey_locations$gps_coordinate) #TODO only a few fields have coordinates, check if it is worth keeping

range(survey_locations$water_temp, na.rm = TRUE) #temp ranges 47-69, and there are two 0s, turning them into NA
table(survey_locations$water_temp)

survey_locations <- survey_locations |> 
  mutate(water_temp = replace(water_temp, water_temp == 0, NA)) |> 
  glimpse()

# write files -------------------------------------------------------------

# save cleaned data to `data/`
write.csv(microhabitat_fish_observations, here::here("data", "microhabitat_with_fish_observations.csv"), row.names = FALSE)

write.csv(survey_locations, here::here("data", "survey_locations.csv"), row.names = FALSE)

