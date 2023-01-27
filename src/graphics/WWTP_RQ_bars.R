WWTP_RQ_bars <- Hugin_Data_Output_Tall_Labelled %>% 
    filter(API_Name %notin% c("Estrogens", "Painkillers"),
           Risk_Bin %notin% c("true", "false"),
                              PGT_Threshold == 100,
           Year_and_Population_Growth == "2050 & Main") %>% 
    ggplot(aes(x = WWT_Scenario, y = Probability, fill = Risk_Bin)) +
    geom_col() +
    scale_fill_brewer(palette = "Spectral", name = "RQ Interval", direction = -1) +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
    facet_grid(rows = vars(API_Name),
               cols = vars(county)) +
    labs(x = "WWT Scenario (2050)") +
    theme_bw()

WWTP_RQ_bars
