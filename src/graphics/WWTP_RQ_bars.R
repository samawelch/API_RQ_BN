WWTP_RQ_bars <- Hugin_Data_Output_Tall %>% 
    filter(master_pop_scenario == "Main", 
           master_year == 2050, 
           master_county %in% c("Nordland", "Viken", "Whole Country"),
           Risk_Bin %notin% c("true", "false"),
           API_Name %in% c("Diclofenac", "AllAPI")) %>%
    mutate(master_county = factor(master_county, levels = c("Nordland", "Viken", "Whole Country"))) %>% 
    ggplot(aes(x = master_WWT_scenario, y = Probability, fill = fct_rev(Risk_Bin))) +
    geom_col(position = "stack") +
    scale_fill_viridis_d("RQ Bin", 
                         option = viridis_colour, 
                         limits = viridis_RQ_mapping, 
                         guide = guide_legend(reverse = TRUE)) +
    facet_grid(rows = vars(API_Name),
               cols = vars(master_county),
               labeller = county_labels) +
    scale_x_discrete(limits = c("Current", "Secondary or better", "Best (tertiary)")) +
    labs(x = "WWT Scenario (2050)")

WWTP_RQ_bars

WWTP_RQ_bars_allAPI <- Hugin_Data_Output_Tall %>%
    filter(master_pop_scenario == "Main",
           master_year == 2020,
           # master_county %in% c("Whole Country"),
           Risk_Bin %notin% c("true", "false")) %>%
    ggplot(aes(x = master_WWT_scenario, y = Probability, fill = Risk_Bin)) +
    geom_col(position = "stack") +
    scale_colour_grey("RQ Bin",
                      aesthetics = "fill",
                      start = 1,
                      end = 0) +
    facet_grid(rows = vars(API_Name), cols = vars(master_county)) +
    scale_x_discrete(limits = c("Current", "Secondary or better", "Best (tertiary)")) +
    labs(x = "WWT Scenario") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 90))

WWTP_RQ_bars_allAPI
