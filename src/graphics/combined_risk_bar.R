combined_RQ_bars <- Hugin_Data_Output_Tall %>% 
    filter(master_pop_scenario == "Main", 
           master_year == 2020, 
           master_county %in% c("Nordland", "Viken"),
           Risk_Bin %notin% c("true", "false"),
           API_Name %notin% c("Estrogens", "Antibiotics","Painkillers")) %>% 
    ggplot(aes(x = API_Name, y = Probability, fill = Risk_Bin)) +
    geom_col(position = "dodge") +
    scale_fill_viridis_d("RQ Bin") +
    facet_grid(rows = vars(master_WWT_scenario),
               cols = vars(master_county)) +
    scale_x_discrete() +
    labs(x = "WWT Scenario") +
    theme(axis.text.x = element_text(angle = 90, vjust = -0.0001))

combined_RQ_bars