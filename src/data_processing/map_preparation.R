# Append county names to the SPL map file, and find centroids for future use

# Append county names to the SPL map
Norway_county_map_names <- Norway_counties_dataframe %>% 
    left_join(county_codes, by = "County_Code") %>% 
    left_join(pop_by_county_2020, by = "County_Name")

# Find the centroids of counties for better labelling
Norway_county_map_centroids <- Norway_county_map_names %>% 
    group_by(County_Name) %>% 
    summarise(lat = mean(range(lat)),
              long = mean(range(long)))

Norway_county_map <- ggplot(data = Norway_county_map_names, mapping = aes(x = long, 
                                                                          y = lat)) + 
    geom_polygon(color = "grey",
                 linewidth = 0.3,
                 aes(group = group)) +
    theme_void() 