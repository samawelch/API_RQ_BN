# Import Statistics Norway data from raw files, and create temp files in a tidy format

### SSB POPULATION BY COUNTY/FYLKE, 2020 BORDERS (11342)
pop_by_county_2020 <- read_excel(path = "data/raw/Statistics_Norway/Pop_2020_Counties.xlsx",
                                 range = "A5:B15",
                                 col_names = c("County", "Population")) %>% 
    transmute(County_Code = str_extract(string = County, pattern = "[0-9]{2}"),
              Population)
# Save to temp
write_csv(x = pop_by_county_2020, file = "data/temp/pop_by_county_2020.csv")

### SSB WWTP TREATMENT AND CONNECTION BY MUNICIPALITY, 2020
# https://www.ssb.no/en/statbank/table/11793/tableViewLayout1/
WWTP_connection_by_municipality <- read_excel(path = "data/raw/Statistics_Norway/Norway_WWTP_Connect_Regions_2020.xlsx", 
                                              skip = 2, 
                                              col_names = c("Municipality", 
                                                            "Pop_Connected_WWTP_>50PE", 
                                                            "Pop_Connected_WWTP_>50PE_Chem_Treat",
                                                            "Pop_Connected_WWTP_>50PE_BioChem_Treat",
                                                            "Pop_Connected_WWTP_>50PE_BioChemMechNat_Treat",
                                                            "Pop_Connected_WWTP_>50PE_No_Treat")) %>% 
    na_if(y = "..") %>% 
    # Remove old kommune and KOSTRA counties
    filter(!is.na(Municipality), 
           `Pop_Connected_WWTP_>50PE` != ".", 
           !str_detect(string = Municipality, pattern = "EAK"),
           !str_detect(string = Municipality, pattern = "EKA"))
write_csv(x = WWTP_connection_by_municipality, file = "data/temp/WWTP_connection_by_municipality.csv")

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


### SSB: wastewater consumption per person per day in Norway 2015 - 2020 (11787)
Norway_Wastewater_Year <- read_xlsx(path = "data/raw/Statistics_Norway/WW_per_PD_2015_2020.xlsx",
                                    range = "B4:G5") %>% 
    # Pivot into long data
    pivot_longer(cols = 1:6,
                 names_to = "Year",
                 values_to = "L_per_person_per_day") %>% 
    # Make sure Year is numeric so it doesn't break everything
    mutate(Year = as.numeric(Year)) %>% 
    # Obviously this doesn't go back far enough, so we'll backfill it to 1999 with fake data
    add_row(Year = 1999:2014, L_per_person_per_day = 180)
write_csv(x = Norway_Wastewater_Year, file = "data/temp/Norway_Wastewater_Year.csv")


### SSB: Norwegian Population Predictions (No Uncertainty Included)
Norway_Population_Projections_21C <- read_xlsx(path = "data/raw/Statistics_Norway/Pop_Forecasts_21C.xlsx",
                                               range = "B5:J7",
                                               col_names = c("Scenario", "2030", "2040", "2050", "2060", 
                                                             "2070", "2080", "2090", "2100")) %>% 
    pivot_longer(cols = 2:9,
                 names_to = "Year",
                 values_to = "Population") %>% 
    mutate(Year = as.double(Year))
write_csv(x = Norway_Population_Projections_21C, file = "data/temp/Norway_Population_Projections_21C.csv")
