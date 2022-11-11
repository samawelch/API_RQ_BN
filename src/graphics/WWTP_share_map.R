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
    theme_void() +
    coord_fixed()

Norway_county_WWT_map

# Pie charts

# Generate some additional scenario pies for the whole country
wwt_share_total_by_scenario <- wwt_share_by_county_2020 %>% filter(County_Name == "Total") %>% 
    crossing(Scenario = c("2+", "3")) %>% 
    arrange(Scenario) %>% 
    mutate(County_Name = paste0(County_Name, Scenario))
# By hand is faster than figuring out how to write the code
wwt_share_total_by_scenario$wwt_pop_share <- c(0, 0, 1 - 0.36459325, 0.36459325,
                                               0, 0, 0, 1)

wwt_share_by_county_scenario <- wwt_share_by_county_2020 %>% rbind(wwt_share_total_by_scenario)
wwt_share_by_county_scenario

Norway_county_pies_WWT <- ggplot(data = wwt_share_by_county_scenario , 
                                 mapping = aes(fill = Class_EU, 
                                               x = 0, 
                                               y = wwt_pop_share,
                                               group = County_Name)) +
    geom_bar(width = 1, stat = "identity") +
    coord_polar(theta = "y") +
    facet_wrap(~County_Name) +
    scale_fill_viridis_d(option = "viridis", begin = 0, end = 0.5) +
    theme_void()

Norway_county_pies_WWT

API_removal_rates_bars <- API_removal_rates %>% 
    mutate(API_Name = fct_relevel(API_Name, c("estradiol", "ethinylestradiol", "ciprofloxacin", "diclofenac",
                                              "ibuprofen", "paracetamol", "mean"))) %>% 
    ggplot(mapping = aes(x = API_Name, 
                         y = removal_rate_perc, 
                         fill = fct_inorder(treatment))) +
    geom_col(position = "dodge") +
    scale_fill_viridis_d(name = "Removal Type", 
                         labels = c("Primary", "Secondary", "Tertiary", "Advanced", "Ozone", "Activated Carbon")) +
    theme_minimal() +
    labs(x = "API", y = "Removal Rate (%)", )

API_removal_rates_bars

wwt_share_by_county_2020 %>% group_by(County_Name) %>% summarise(sum((wwt_pop_share)))
