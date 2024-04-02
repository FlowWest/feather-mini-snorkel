library(tidyverse)
library(googleCloudStorageR)


# google cloud set up
# gcs_auth(json_file = Sys.getenv("GCS_AUTH_FILE"))
# gcs_global_bucket(bucket = Sys.getenv("GCS_DEFAULT_BUCKET"))
# 
# # get data from google cloud
# gcs_get_object(object_name = "juvenile-rearing-monitoring/seine-and-snorkel-data/feather-river/data/combined_feather_snorkel_data.csv",
#                bucket = gcs_get_global_bucket(),
#                saveToDisk =  here::here("data-raw", ""),
               # overwrite = TRUE)

fish_observations <- read_csv(here::here("data", "microhabitat_with_fish_observations.csv"))

survey_locations <- read_csv(here::here("data", "survey_locations.csv"))

# clean data --------------------------------------------------------------
# here is where we clean up the data and make sure it all looks as expected
# check unique values for each column
# check that all fields are being read in the right way





# write files -------------------------------------------------------------

# save cleaned data to `data/`
write.csv(data_name, here::here("data", ""), row.names = FALSE)

