# Make a map of Norway in 2020 and 2050 (main/current scenario), with 
# - most probable RQ interval displayed as a chloropleth
# - RQ distribution for Viken and Nordland, plus total, as pie charts
# - an accompanying table of extra data?

Norway_county_map_RQ_data <- Norway_county_map_names %>% 
    left_join(Hugin_Data_Output_Tall, by = c("County_Name" = "master_county")) %>% 
    filter(master_pop_scenario == "Main", master_WWT_scenario == "Current", API_Name == "Total",
           Risk_Bin %notin% c("true", "false")) %>% 
    group_by(County_Name, master_year) %>% 
    # What's the most probable bin?
    filter(Probability == max(Probability)) %>% 
    # Give selected regions thicke rlines so they stand out
    mutate(county_linewidth = case_when(County_Name %in% c("Viken", "Nordland") ~ 2,
                                  TRUE ~ 1))

Norway_county_RQ_map <- ggplot(data = Norway_county_map_RQ_data, mapping = aes(x = long, 
                                                                             y = lat,
                                                                             fill = Risk_Bin,
                                                                             group = county_linewidth)) + 
    geom_polygon(data = Norway_county_map_RQ_data %>% filter(county_linewidth == 1),
                 color = "grey",
                 size = 0.5,
                 aes(group = group,
                     fill = Risk_Bin)) +
    geom_polygon(data = Norway_county_map_RQ_data %>% filter(county_linewidth == 2),
                 color = "#555555",
                 size = 0.5,
                 aes(group = group,
                     fill = Risk_Bin)) +
    # Since only two intervals are most probably we need to tighten the gamut of possible values 
    scale_fill_viridis_d(option = viridis_colour, begin = 0.66, end = 0.83) +
    facet_wrap(facets = vars(master_year)) +
    theme_void()

Norway_county_RQ_map

# Pie Charts for Individual Counties
Norway_county_pie_RQ_data <- Hugin_Data_Output_Tall %>% 
    filter(master_pop_scenario == "Main", 
           master_WWT_scenario == "Current", 
           API_Name == "Total",
           Risk_Bin %notin% c("true", "false"),
           master_county %in% c("Nordland", "Viken", "Total"))

Norway_county_pies_RQ <- ggplot(data = Norway_county_pie_RQ_data, aes(fill = Risk_Bin, x = "", y = Probability)) +
    geom_bar(width = 1, stat = "identity") +
    coord_polar(theta = "y", start = 1) +
    facet_wrap(facets = vars(master_county, master_year)) +
    scale_fill_viridis_d(option = viridis_colour) +
    theme_void()