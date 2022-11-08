# Make a map of Norway with pie charts per fylke depicting access to various WWTP levels
# I'd love to do this automatically, but scatterpie is too primitive and I'm strapped for time

Norway_county_map_WWT_data <- Norway_county_map_names %>% 
    left_join(wwt_share_by_county_2020, by = c("County_Name"))


Norway_county_WWT_map <- ggplot(data = Norway_county_map_WWT_data, mapping = aes(x = long, 
                                                                               y = lat)) + 
    geom_polygon(fill = "lightgrey",
                 colour = "white",
                 size = 0.5,
                 aes(group = group)) +
    theme_void()

Norway_county_WWT_map

# Pie charts

Norway_county_pies_WWT <- ggplot(data = wwt_share_by_county_2020 %>% filter(County_Name != "Total"), 
                                 mapping = aes(fill = Class_EU, 
                                               x = 0, 
                                               y = wwt_pop_share,
                                               group = County_Name)) +
    geom_bar(width = 1, stat = "identity") +
    # coord_polar(theta = "y") +
    facet_wrap(~County_Name) +
    scale_fill_viridis_d(option = "viridis") +
    theme_void()

Norway_county_pies_WWT

wwt_share_by_county_2020 %>% group_by(County_Name) %>% summarise(sum((wwt_pop_share)))
