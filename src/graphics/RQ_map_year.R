# Make a map of Norway in 2020 and 2050 (main/current scenario), with 
# - most probable RQ interval displayed as a chloropleth
# - RQ distribution for Viken and Nordland, plus total, as pie charts
# - an accompanying table of extra data?

Norway_county_map_RQ_data <- Norway_county_map_names %>% 
    left_join(Hugin_Data_Output_Tall, by = c("County_Name" = "master_county")) %>% 
    filter(master_pop_scenario == "Main", master_WWT_scenario == "Current", API_Name == "AllAPI",
           Risk_Bin %notin% c("true", "false")) %>% 
    group_by(County_Name, master_year) %>% 
    # What's the most probable bin?
    filter(Probability == max(Probability)) %>% 
    # Give selected regions thicker lines so they stand out
    mutate(county_linewidth = case_when(County_Name %in% c("Viken", "Nordland") ~ 2,
                                  TRUE ~ 1))

# Pie Charts for Individual Counties
Norway_county_pie_RQ_data <- Hugin_Data_Output_Tall %>% 
    filter(master_pop_scenario == "Main", 
           master_WWT_scenario == "Current", 
           API_Name == "AllAPI",
           Risk_Bin %notin% c("true", "false"),
           master_county %in% c("Nordland", "Viken", "Whole Country"))

Norway_county_pies_RQ <- ggplot(data = Norway_county_pie_RQ_data, aes(fill = Risk_Bin, x = "", y = Probability)) +
    geom_bar(width = 1, stat = "identity") +
    coord_polar(theta = "y", start = 1) +
    facet_wrap(facets = vars(master_county, master_year)) +
    scale_fill_viridis_d(option = viridis_colour, limits = viridis_RQ_mapping) +
    theme_void()


Norway_county_RQ_map <- ggplot(data = Norway_county_map_RQ_data, mapping = aes(x = long, 
                                                                               y = lat,
                                                                               fill = Risk_Bin,
                                                                               group = county_linewidth)) + 
    geom_polygon(data = Norway_county_map_RQ_data %>% filter(county_linewidth == 1),
                 color = "grey",
                 size = 0.08,
                 aes(group = group,
                     fill = Risk_Bin)) +
    geom_polygon(data = Norway_county_map_RQ_data %>% filter(county_linewidth == 2),
                 color = "#555555",
                 size = 0.08,
                 aes(group = group,
                     fill = Risk_Bin)) +
    scale_fill_viridis_d(name = "RQ Bin", option = viridis_colour, limits = viridis_RQ_mapping) +
    facet_wrap(facets = vars(master_year)) +
    theme_void() +
    labs(title = "(a)")

Norway_county_RQ_map

# Full Risk Distributions for All Counties 2020 & 2050
Norway_county_bars_RQ <- Hugin_Data_Output_Tall %>% 
    filter(master_pop_scenario == "Main", master_WWT_scenario == "Current", API_Name == "AllAPI", Risk_Type == "SumRQ") %>% 
    ggplot(mapping = aes(x = master_year , y = Probability, fill = Risk_Bin)) +
    geom_col() +
    scale_x_continuous(breaks = c(2020, 2050)) +
    scale_fill_viridis_d(option = viridis_colour, name = "RQ Bin", limits = viridis_RQ_mapping) +
    facet_grid(cols = vars(master_county), labeller = labeller(master_county = label_wrap_gen(width = 12))) +
    labs(x = "County and Year", y = "Probability", title = "(b)")

Norway_county_bars_RQ

# Can we break down these risk distributions to something more useful for driver analysis?
Hugin_Data_Output_Tall %>% 
    filter(master_pop_scenario == "Main", master_WWT_scenario == "Current", Risk_Type != "PRQ_GT") %>% 
    ggplot(mapping = aes(x = master_year, y = Probability, fill = Risk_Bin)) +
    geom_col() +
    scale_fill_viridis_d(option = viridis_colour, name = "RQ Bin", limits = viridis_RQ_mapping) +
    scale_x_continuous(breaks = c(2020, 2050)) +
    facet_grid(rows = vars(API_Name), cols = vars(master_county)) +
    labs(x = "Year", y = "Probability")

Hugin_Data_Output_Tall %>% 
    filter(master_pop_scenario == "Main", master_WWT_scenario == "3", Risk_Type != "PRQ_GT") %>% 
    ggplot(mapping = aes(x = master_year, y = Probability, fill = Risk_Bin)) +
    geom_col() +
    scale_fill_viridis_d(option = viridis_colour, name = "RQ Bin", limits = viridis_RQ_mapping) +
    scale_x_continuous(breaks = c(2020, 2050)) +
    facet_grid(rows = vars(API_Name), cols = vars(master_county)) +
    labs(x = "Year", y = "Probability")
