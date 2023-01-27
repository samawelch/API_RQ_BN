# Import Statistics Norway data from raw files, and create temp files in a tidy format

### SSB POPULATION BY COUNTY/FYLKE, 2020 BORDERS (11342)
pop_by_county_2020 <- read_excel(path = "data/raw/Statistics_Norway/Pop_2020_Counties.xlsx",
                                 range = "A5:B15",
                                 col_names = c("County", "Population")) %>% 
    transmute(County_Name = str_extract(string = County, pattern = "[A-z](?:(?! -).)*"),
              Population)
# Save to temp
write_csv(x = pop_by_county_2020, file = "data/temp/pop_by_county_2020.csv")

# Import a table of Norwegian and English language WWT technology definitions
# Own work, adapted from Statistics Norway reports

WWT_definitions_Norway <- read_excel(path = "data/raw/WWT_definitions_norway.xlsx")

### SSB: Inhabitants Connected to Small WWTPs (05272)
# https://www.ssb.no/statbank/table/05272/
small_wwtp_by_county_2020 <- read_excel(path = "data/raw/Statistics_Norway/WWTP_by_County_2020_Small.xlsx", 
                                        range = "A6:P16",
                                        col_names = c("County",
                                                      "total",
                                                      "untreated",
                                                      "sludge_seperator",
                                                      "biological",
                                                      "chemical",
                                                      "chemical-biological",
                                                      "sludge_seperator_w_infiltration",
                                                      "sludge_seperator_w_sand_filter",
                                                      "sealed_blackwater_tank",
                                                      "biological_toilet",
                                                      "sealed_greywater_tank",
                                                      "artificial_wetland",
                                                      "sealed_blackwater_greywater_filter",
                                                      "biological_toilet_greywater_filter",
                                                      "other"),
                                        na = "..") %>% 
    mutate(County_Code = str_extract(string = County, pattern = "[0-9]{2}"),
           # Remove the numbers at the start of County, and the Sapmi name if present
           County_Name = str_extract(string = County, pattern = "[A-z](?:(?! -).)*")) %>% 
    select(-County)
write_csv(x = small_wwtp_by_county_2020, file = "data/temp/small_wwtp_by_county_2020.csv")


### SSB: Inhabitants Connected to Large WWTPs (05273)
# https://www.ssb.no/statbank/table/05273/
large_wwtp_by_county_2020 <- read_excel(path = "data/raw/Statistics_Norway/WWTP_by_County_2020_Large.xlsx", 
                                        range = "A6:H16",
                                        col_names = c("County",
                                                      "total",
                                                      "untreated",
                                                      "mechanical",
                                                      "chemical",
                                                      "biological",
                                                      "chemical-biological",
                                                      "other"),
                                        na = "..") %>% 
    mutate(County_Code = str_extract(string = County, pattern = "[0-9]{2}"),
           County_Name = str_extract(string = County, pattern = "[A-z](?:(?! -).)*")) %>% 
    select(-County) 
write_csv(x = large_wwtp_by_county_2020, file = "data/temp/large_wwtp_by_county_2020.csv")

# Merge data for access to large and small WWTP in Norway 2020, by county
# Convert Norwegian names to English/EU classes, based on WWT_definitions_Norway

wwtp_by_county_2020 <- large_wwtp_by_county_2020 %>% 
    pivot_longer(cols = 1:7, names_to = "treatment", values_to = "population") %>% 
    mutate(size = "large") %>% 
    add_row(
        small_wwtp_by_county_2020 %>% 
            pivot_longer(cols = 1:15, names_to = "treatment", values_to = "population") %>% 
            mutate(size = "small")
    ) %>% 
    left_join(WWT_definitions_Norway %>% select(Name_EN, Class_EU), by = c("treatment" = "Name_EN")) %>% 
    # This double counts for some reason
    distinct()


# In any case, we can now characterise the proportions of different treatment levels in each County
wwt_share_by_county_2020 <- 
    wwtp_by_county_2020 %>% 
    filter(treatment != "total") %>% 
    group_by(County_Name, Class_EU) %>% 
    summarise(County_Name,
              population = sum(population, na.rm = TRUE)) %>% 
    distinct() %>% 
    ungroup() %>% 
    # Also calculate a national total
    add_row(wwtp_by_county_2020 %>% 
                group_by(Class_EU) %>% 
                filter(!is.na(Class_EU)) %>% 
                summarise(County_Name = "Total", 
                          population = sum(population, na.rm = TRUE))) %>% 
    group_by(County_Name) %>% 
    mutate(wwt_pop_share = population / sum(population))



# Create a helper csv matching county codes to names
county_codes <- large_wwtp_by_county_2020 %>% 
    select(County_Code, County_Name)
write_csv(x = county_codes, file = "data/temp/county_codes.csv")


### SSB: mainland Norwegian population on 1 Jan per year 1951 - 2021 (06913)

Norway_Population_Year <- read_xlsx(path = "data/raw/Statistics_Norway/Pop_1951_2021.xlsx",
                                    range = "B4:C74",
                                    col_names = c("Year", "Population")) %>% 
    mutate(Year = as.numeric(Year))
write_csv(x = Norway_Population_Year, file = "data/temp/Norway_Population_Year.csv")


### SSB: Water consumption per person per day (11787) by County
Norway_Wastewater_County_2020 <- read_excel("data/raw/Statistics_Norway/WW_production_by_County_2020.xlsx",
                                            range = "A5:B15",col_names = c("County_Name", "Consumption_PPerson_PDay")) %>% 
    mutate(County_Name = str_remove(string = County_Name, pattern = "EKA[0-9]{2} "))


### SSB: Norwegian Population Predictions (No Uncertainty Included)
Norway_Population_Projections_21C <- read_xlsx(path = "data/raw/Statistics_Norway/Pop_Forecasts_21C.xlsx",
                                               range = "B5:J7",
                                               col_names = c("Scenario", "2030", "2040", "2050", "2060", 
                                                             "2070", "2080", "2090", "2100")) %>% 
    pivot_longer(cols = 2:9,
                 names_to = "Year",
                 values_to = "Population") %>% 
    mutate(Year = as.double(Year),
           # Compare to population in 2020
           Pop_over_2020 = Population / 5367580)
write_csv(x = Norway_Population_Projections_21C, file = "data/temp/Norway_Population_Projections_21C.csv")

### SSB: 05212: Population, by region, contents, year and densely/sparsely populated areas
Norway_County_Urbanisation_2020 <- read_xlsx(path = "data/raw/Statistics_Norway/Norway_Pop_Urban.xlsx",
                                             range = "A6:C16",
                                             col_names = c("County", "Pop_Dense_Area", "Pop_Sparse_Area")) %>% 
    transmute(County_Name = str_extract(string = County, pattern = "[A-z](?:(?! -).)*") %>% 
                  str_replace(" og ", " & "),
              pop_urban = Pop_Dense_Area / (Pop_Dense_Area + Pop_Sparse_Area),
              quantile = ntile(x = pop_urban,
                               n = 3))

# Merge relevant urban data into a single dataset
Norway_County_General_2020 <- Norway_County_Urbanisation_2020 %>% 
    left_join(Norway_Wastewater_County_2020, by = "County_Name") %>% 
    mutate(urb_quantile = case_when(quantile == 1 ~ "Rural", 
                                    quantile == 2 ~ "Semi-Urban", 
                                    quantile == 3 ~ "Urban")) %>% 
    left_join(pop_by_county_2020, by = "County_Name") %>% 
    mutate(Annual_WW_ML = Population * Consumption_PPerson_PDay * 365 / 1e6) %>% 
    left_join(
        wwtp_by_county_2020 %>% 
        select(-size, -County_Code) %>% 
        filter(!is.na(Class_EU)) %>% 
        group_by(Class_EU, County_Name) %>% 
        summarise(population = sum(population, na.rm = TRUE)) %>% 
        group_by(County_Name) %>% 
        mutate(population_frac = population / sum(population, na.rm = TRUE)) %>% 
        select(-population) %>% 
        pivot_wider(names_from = Class_EU, values_from = population_frac),
        by = "County_Name") %>% 
    replace_na(list(none = 0, primary = 0, secondary = 0, tertiary = 0)) %>% 
    relocate(County_Name, urb_quantile, Population, Annual_WW_ML, none, primary, secondary, tertiary) %>% 
    select(-quantile) %>% 
    mutate(exemplar = case_when(County_Name %in% c("Viken", "Trøndelag", "Troms & Finnmark") ~ TRUE,
                                 TRUE ~ FALSE)) %>% 
    mutate(Arbitrary_WWT_Index = (primary * 1 + secondary * 2 + tertiary * 3) / 3) %>% 
    mutate(Pop_mil = Population / 1e6,
           Type = case_when(!exemplar ~ urb_quantile,
                            TRUE ~ paste0(urb_quantile, ", exemplar")))

