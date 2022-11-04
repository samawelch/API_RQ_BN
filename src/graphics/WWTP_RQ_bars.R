WWTP_RQ_bars <- Hugin_Data_Output_Tall %>% 
    filter(master_pop_scenario == "Main", 
           master_year == 2020, 
           master_county %in% c("Nordland", "Viken"),
           Risk_Bin %notin% c("true", "false"),
           API_Name %in% c("Ethinylestradiol", "Total")) %>% 
    ggplot(aes(x = master_WWT_scenario, y = Probability, fill = Risk_Bin)) +
    geom_col(position = "stack") +
    scale_fill_viridis_d("RQ Bin") +
    facet_grid(rows = vars(API_Name),
               cols = vars(master_county)) +
    scale_x_discrete(limits = c("Current", "Compliance")) +
    labs(x = "WWT Scenario")

WWTP_RQ_bars