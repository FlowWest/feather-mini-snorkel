library(EDIutils)
library(tidyverse)
library(EMLaide)
library(readxl)
library(EML)

datatable_metadata <-
  dplyr::tibble(filepath = c("data/survey_locations.csv",
                             "data/microhabitat_with_fish_observations.csv"),
                attribute_info = c("data-raw/metadata/feather_survey_locations_metadata.xlsx",
                                   "data-raw/metadata/feather_microhabitat_metadata.xlsx"),
                datatable_description = c("Feather river mini snorkel survey locations data",
                                          "Feather river mini snorkel survey microhabitat data"),
                datatable_url = paste0("https://github.com/FlowWest/feather-mini-snorkel/make-metadata/data",
                                       c("feather_survey_locations_metadata.csv",
                                         "microhabitat_with_fish_observations.csv")))
# save cleaned data to `data/`
excel_path <- "data-raw/metadata/feather_metadata.xlsx" 
sheets <- readxl::excel_sheets(excel_path)
metadata <- lapply(sheets, function(x) readxl::read_excel(excel_path, sheet = x))
names(metadata) <- sheets

abstract_docx <- "data-raw/metadata/abstract.docx"
methods_docx <- "data-raw/metadata/methods.docx"

#edi_number <- reserve_edi_id(user_id = Sys.getenv("EDI_USER_ID"), password = Sys.getenv("EDI_PASSWORD"))
edi_number <- "feather-mini-snorkel"

dataset <- list() %>%
  add_pub_date() %>%
  add_title(metadata$title) %>%
  add_personnel(metadata$personnel) %>%
  add_keyword_set(metadata$keyword_set) %>%
  add_abstract(abstract_docx) %>%
  add_license(metadata$license) %>%
  add_method(methods_docx) %>%
  add_maintenance(metadata$maintenance) %>%
  add_project(metadata$funding) %>%
  add_coverage(metadata$coverage, metadata$taxonomic_coverage) %>%
  add_datatable(datatable_metadata)

# GO through and check on all units
custom_units <- data.frame(id = c("river mile", "number of divers", "NTU", "count of fish"),
                           unitType = c("dimensionless", "dimensionless", "dimensionless", "dimensionless"),
                           parentSI = c(NA, NA, NA, NA),
                           multiplierToSI = c(NA, NA, NA, NA),
                           description = c("river mile", "number of divers", "NTU", "count of fish"))


unitList <- EML::set_unitList(custom_units)

eml <- list(packageId = edi_number,
            system = "EDI",
            access = add_access(),
            dataset = dataset,
            additionalMetadata = list(metadata = list(unitList = unitList))
)
edi_number
EML::write_eml(eml, paste0(edi_number, ".xml"))
EML::eml_validate(paste0(edi_number, ".xml"))


# save cleaned data to `data/`
