pop_scen_RQ_bars <- Hugin_Data_Output_Tall %>% 
    filter(master_WWT_scenario == "Current", 
           master_year == 2050, 
           master_county %in% c("Nordland", "Viken", "Whole Country"),
           Risk_Bin %notin% c("true", "false"),
           API_Name %in% c("Diclofenac", "AllAPI")) %>% 
    mutate(master_county = factor(master_county, levels = c("Nordland", "Viken", "Whole Country"))) %>% 
    ggplot(aes(x = master_pop_scenario, y = Probability, fill = fct_rev(Risk_Bin))) +
    geom_col(position = "stack") +
    scale_fill_viridis_d("RQ Bin", 
                         option = viridis_colour, 
                         limits = viridis_RQ_mapping,
                         guide = guide_legend(reverse = TRUE)) +
    facet_grid(rows = vars(API_Name),
               cols = vars(master_county), 
               labeller = county_labels) +
    scale_x_discrete(limits = c("Low", "Main", "High")) +
    labs(x = "Population Growth Scenario, 2050")

pop_scen_RQ_bars

# Full graphic

Hugin_Data_Output_Tall %>% 
    filter(master_WWT_scenario == "Current", 
           master_year == 2050, 
           Risk_Bin %notin% c("true", "false")) %>% 
    ggplot(aes(x = master_pop_scenario, y = Probability, fill = fct_rev(Risk_Bin))) +
    geom_col(position = "stack") +
    scale_fill_viridis_d("RQ Bin", option = viridis_colour, 
                         limits = viridis_RQ_mapping,
                         guide = guide_legend(reverse = TRUE)) +
    facet_grid(rows = vars(API_Name),
               cols = vars(master_county)) +
    scale_x_discrete(labels = c("L" = "Low", "M" = "Main", "H" = "High")) +
    labs(x = "Population Growth Scenario, 2050")