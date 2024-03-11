# The goal of this script is to read in data from the mdb file in preparation for processing

library(tidyverse)
library(knitr)
library(Hmisc)
library(lubridate)

mini_snork_db <- here::here("data-raw", "MiniSnorkelDTB.mdb")
mdb.get(mini_snork_db, tables = T)

# tables
all_fish_obs <- mdb.get(mini_snork_db, tables = "All fish observations")
phys_hab_available <- mdb.get(mini_snork_db, tables = "chn0 Phys Avail for All Fish") # subset of all_fish_obs, physical habitat associated with grid chinook salmon found
phys_hab_available_minus_obs <- mdb.get(mini_snork_db, tables = "chn0 Phys Avail minus observations") # same number of obs/rows as above
phys <- mdb.get(mini_snork_db, tables = "PhysDataTbl")
rbt0_phys_available <- mdb.get(mini_snork_db, tables = "rbt0 Phys Avail for All Fish")
rbt1_phys_available <- mdb.get(mini_snork_db, tables = "rbt1 Phys Avail for All Fish")
rbt0_phys_available_minus_obs <- mdb.get(mini_snork_db, tables = "rbt0 Phys Avail minus observations") # same number of obs/rows as above
rbt1_phys_available_minus_obs <- mdb.get(mini_snork_db, tables = "rbt1 Phys Avail minus observations") # same number of obs/rows as above
fish_data <- mdb.get(mini_snork_db, tables = "FishDataTBL")
microhabitat <- mdb.get(mini_snork_db, tables = "MicroHabDataTbl")
microhabitat_rbt_use_2001 <- mdb.get(mini_snork_db, tables = "Microhabitat Avail and RBT Use 2001")
rbt_reach <- mdb.get(mini_snork_db, tables = "RBT Reach Data Flat 2001")
reach_summary <- mdb.get(mini_snork_db, tables = "Reach Habitat Summary")
canopy_cover <- mdb.get(mini_snork_db, tables = "CanopyCover")
comments <- mdb.get(mini_snork_db, tables = "Comments")

# lookups
cgu_code_lookup <- mdb.get(mini_snork_db, tables = "CGUCodeLookUp")
channel_lookup <- mdb.get(mini_snork_db, tables = "ChannelTypeLookUp")
instream_cover_lookup <- mdb.get(mini_snork_db, tables = "ICoverLookUp")
overhead_cover_lookup <- mdb.get(mini_snork_db, tables = "OCoverLookUp")
species_code_lookup <- mdb.get(mini_snork_db, tables = "SpeciesCodeLookUp")
weather_code_lookup <- mdb.get(mini_snork_db, tables = "WeatherCodeLookUp")
substrate_code_lookup <- mdb.get(mini_snork_db, tables = "SubstrateCodeLookUp")
# transect_canopy <- mdb.get(mini_snork_db, tables = "TransectCanopy") # empty

