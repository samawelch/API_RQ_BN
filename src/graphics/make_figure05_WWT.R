# Draw discrete probability distributions (as lines) for 6 APIs across 3 WWT Scenarios
figure05_data <- Hugin_Data_Output_Tall_Labelled |> 
    filter(Year_and_Population_Growth  == "2020 & None",
           API_Name %notin% c("Estrogens", "Analgesics"))

figure05_WWT <- ggplot(data = figure05_data,
                       aes(y = Probability, 
                           x = fct_inorder(Risk_Bin), 
                           colour = WWT_Scenario, 
                           group = WWT_Scenario, 
                           linetype = WWT_Scenario)) +
    geom_step(direction = "mid", 
              linewidth = 1) +
    scale_linetype_manual(values = c("solid", "11", "12"),
                          name = "WWT Scenario") +
    facet_grid(rows = vars(API_Name), 
               cols = vars(county)) +
    theme_bw() +
    scale_colour_manual(values = c("grey", "#0040FF", "#11EE67"),
                        name = "WWT Scenario") +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(x = "RQ Interval", y = "Probability") +
    guides(guide_legend()) +
    theme(legend.position = "bottom")

figure05_WWT
