# Import shapefiles from the Norwegian Institute for Public Health's
# Sykdompuls family of packages (splmaps)
# make a small format modification

# Dataframe version
Norway_counties_dataframe <- nor_nuts3_map_b2020_default_dt %>% 
    mutate(County_Code = str_extract(string = location_code, pattern = "[0-9]{2}"))
write_csv(x = Norway_counties_dataframe, file = "data/temp/Norway_counties_dataframe.csv")

# sf version
Norway_counties_sf <- nor_nuts3_map_b2020_default_sf %>% 
    mutate(County_Code = str_extract(location_code, pattern = "[0-9]{2}"))
write_csv(x = Norway_counties_sf, file = "data/temp/Norway_counties_sf.csv")