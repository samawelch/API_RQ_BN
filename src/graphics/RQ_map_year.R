# Make a map of Norway in 2020 and 2050 (main/current scenario), with 
# - most probable RQ interval displayed as a chloropleth
# - RQ distribution for Viken and Nordland, plus total, as pie charts
# - an accompanying table of extra data?

# This isn't a very meaningful map.
# Norway_county_map_RQ_data <- Hugin_Data_Output_Tall_Labelled %>% 
#     filter(WWT_Scenario  == "Current", 
#            API_Name == "AllAPI",
#            Risk_Bin %notin% c("true", "false")) %>% 
#     group_by(county, Year_and_Population_Growth) %>% 
#     filter(Probability == max(Probability))
# 
# Norway_county_map_RQ_data
# 
# 
# Norway_county_RQ_map <- ggplot(data = Norway_county_map_RQ_data, mapping = aes(x = long, 
#                                                                                y = lat,
#                                                                                fill = Risk_Bin,
#                                                                                group = county_linewidth)) + 
#     geom_polygon(data = Norway_county_map_RQ_data %>% filter(county_linewidth == 1),
#                  color = "grey",
#                  size = 0.08,
#                  aes(group = group,
#                      fill = Risk_Bin)) +
#     geom_polygon(data = Norway_county_map_RQ_data %>% filter(county_linewidth == 2),
#                  color = "#555555",
#                  size = 0.08,
#                  aes(group = group,
#                      fill = Risk_Bin)) +
#     scale_fill_viridis_d(name = "RQ Bin", option = viridis_colour, limits = viridis_RQ_mapping) +
#     facet_wrap(facets = vars(master_year)) +
#     theme_void() +
#     labs(title = "(a)")
# 
# Norway_county_RQ_map

# Full Risk Distributions for All Counties 2020 & 2050
# Norway_county_bars_RQ <- Hugin_Data_Output_Tall_Labelled %>% 
#     filter(master_pop_scenario == "Main", master_WWT_scenario == "Current", API_Name == "AllAPI", Risk_Type == "SumRQ") %>% 
#     ggplot(mapping = aes(x = master_year , y = Probability, fill = Risk_Bin)) +
#     geom_col() +
#     scale_x_continuous(breaks = c(2020, 2050)) +
#     scale_fill_viridis_d(option = viridis_colour, name = "RQ Bin", limits = viridis_RQ_mapping) +
#     facet_grid(cols = vars(master_county), labeller = labeller(master_county = label_wrap_gen(width = 12))) +
#     labs(x = "County and Year", y = "Probability", title = "(b)")
# 
# Norway_county_bars_RQ

# Can we break down these risk distributions to something more useful for driver analysis?
RQ_Distribts_by_Year_Growth <- Hugin_Data_Output_Tall_Labelled %>% 
    filter(WWT_Scenario  == "Current", 
           API_Name %notin% c("Estrogens", "Painkillers"),
           Risk_Bin %notin% c("true", "false"),
           PGT_Threshold == 100) %>% 
    mutate(Year_and_Population_Growth = str_remove(Year_and_Population_Growth, " &")) %>% 
    ggplot(mapping = aes(x = Year_and_Population_Growth, y = Probability, fill = Risk_Bin)) +
    geom_col() +
    scale_fill_brewer(palette = "Spectral", name = "RQ Interval", direction = -1) +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 5)) +
    facet_grid(rows = vars(API_Name), cols = vars(county)) +
    labs(x = "Year", y = "Probability") +
    theme_bw()

RQ_Distribts_by_Year_Growth