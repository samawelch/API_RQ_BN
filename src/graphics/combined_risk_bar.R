combined_RQ_bars <- Hugin_Data_Output_Tall_Labelled %>% 
    filter(WWT_Scenario  == "Best (all tertiary)", 
           API_Name %notin% c("Estrogens", "Painkillers"),
           Risk_Bin %in% c("true", "false")) %>% 
    ggplot(aes(x = WWT_Scenario, y = Probability, fill = Risk_Bin)) +
    scale_fill_brewer(palette = "RdYlBu", name = "RQ Interval", direction = -1) +
    geom_col(position = "stack") +
    facet_grid(cols = vars(county)) +
    scale_x_discrete() +
    labs(x = "WWT Scenario (2050)") +
    theme(axis.text.x = element_text(angle = 90, vjust = -0.0001))

combined_RQ_bars
