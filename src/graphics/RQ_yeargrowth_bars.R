RQ_Distribts_by_Year_Growth <- Hugin_Data_Output_Tall_Labelled %>% 
    filter(WWT_Scenario  == "Current", 
           API_Name %notin% c("Estrogens", "Painkillers"),
           Risk_Bin %notin% c("true", "false"),
           PGT_Threshold == 100) %>% 
    mutate(Year_and_Population_Growth = str_remove(Year_and_Population_Growth, " &")) %>% 
    ggplot(mapping = aes(x = fct_inorder(Year_and_Population_Growth), y = Probability, fill = Risk_Bin)) +
    geom_col() +
    scale_fill_brewer(palette = "Spectral", name = "RQ Interval", direction = -1) +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 5)) +
    facet_grid(rows = vars(API_Name), cols = vars(county)) +
    labs(x = "Year", y = "Probability") +
    theme_bw()

RQ_Distribts_by_Year_Growth