WWTP_RQ_bars <- Hugin_Data_Output_Tall %>% 
    filter(master_pop_scenario == "Main", 
           master_year == 2020, 
           master_county %in% c("Nordland", "Viken", "Total"),
           Risk_Bin %notin% c("true", "false"),
           API_Name %in% c("Ethinylestradiol", "Total")) %>%
    mutate(master_county = factor(master_county, levels = c("Nordland", "Viken", "Total"))) %>% 
    ggplot(aes(x = master_WWT_scenario, y = Probability, fill = fct_rev(Risk_Bin))) +
    geom_col(position = "stack") +
    scale_fill_viridis_d("RQ Bin", option = viridis_colour, direction = -1) +
    facet_grid(rows = vars(API_Name),
               cols = vars(master_county),
               labeller = county_labels) +
    scale_x_discrete(limits = c("Current", "Compliance", "Upgrade")) +
    labs(x = "WWT Scenario")

WWTP_RQ_bars

# WWTP_RQ_bars_allAPI <- Hugin_Data_Output_Tall %>% 
#     filter(master_pop_scenario == "Main", 
#            master_year == 2020, 
#            master_county %in% c("Total"),
#            Risk_Bin %notin% c("true", "false")) %>% 
#     ggplot(aes(x = master_WWT_scenario, y = Probability, fill = Risk_Bin)) +
#     geom_col(position = "stack") +
#     scale_fill_viridis_d("RQ Bin") +
#     facet_grid(cols = vars(API_Name)) +
#     scale_x_discrete(limits = c("Current", "Compliance", "Upgrade")) +
#     labs(x = "WWT Scenario")
# 
# WWTP_RQ_bars_allAPI
