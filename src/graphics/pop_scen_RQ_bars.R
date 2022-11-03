pop_scen_RQ_bars <- Hugin_Data_Output_Tall %>% 
    filter(master_WWT_scenario == "Current", 
           master_year == 2050, 
           master_county %in% c("Nordland", "Viken"),
           Risk_Bin %notin% c("true", "false"),
           API_Name %in% c("Ethinylestradiol", "Total")) %>% 
    ggplot(aes(x = master_pop_scenario, y = Probability, fill = Risk_Bin)) +
    geom_col(position = "dodge") +
    scale_fill_viridis_d("RQ Bin") +
    facet_grid(rows = vars(API_Name),
               cols = vars(master_county)) +
    scale_x_discrete(limits = c("Low", "Main", "High")) +
    labs(x = "Population Growth Scenario, 2050")