# Append county names to the SPL map file, and find centroids for future use

# Append county names to the SPL map
Norway_county_map_names <- Norway_counties_sf %>% 
    left_join(county_codes, by = "County_Code") %>% 
    left_join(pop_by_county_2020, by = "County_Name")

# Find the centroids of counties for better labelling
# Norway_county_map_centroids <- Norway_county_map_names %>% 
#     group_by(County_Name) %>% 
#     st_centroid()

Norway_county_map <- ggplot(data = Norway_county_map_names) + 
    geom_sf(color = "grey",
                 linewidth = 0.3) +
    theme_void() 