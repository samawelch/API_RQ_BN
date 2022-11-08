combined_RQ_bars <- Hugin_Data_Output_Tall %>% 
    filter(master_pop_scenario == "Main", 
           master_year == 2020, 
           master_county %in% c("Nordland", "Viken", "Total"),
           Risk_Bin %notin% c("true", "false"),
           API_Name %notin% c("Estrogens", "Antibiotics","Painkillers")) %>% 
    mutate(master_county = factor(master_county, levels = c("Nordland", "Viken", "Total"))) %>% 
    ggplot(aes(x = master_WWT_scenario, y = Probability, fill = fct_rev(Risk_Bin))) +
    geom_col(position = "stack") +
    scale_fill_viridis_d("RQ Bin", option = viridis_colour, direction = -1) +
    facet_grid(rows = vars(master_county),
               cols = vars(API_Name), 
               labeller = county_labels) +
    scale_x_discrete() +
    labs(x = "WWT Scenario") +
    theme(axis.text.x = element_text(angle = 90, vjust = -0.0001))

combined_RQ_bars