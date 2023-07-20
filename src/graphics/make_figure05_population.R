RQ_Distribts_by_Year_Growth <- Hugin_Data_Output_Tall_Labelled |> 
    filter(WWT_Scenario  == "Current", 
           Year_and_Population_Growth == "2050 & High",
           API_Name %notin% c("Estrogens", "Analgesics"),
           Risk_Bin %notin% c("true", "false")) |> 
    mutate(Year_and_Population_Growth = str_remove(Year_and_Population_Growth, " &")) |> 
    ggplot(mapping = aes(x = fct_inorder(Risk_Bin), y = Probability, fill = fct_inorder(Risk_Bin), colour = fct_inorder(Risk_Bin))) +
    geom_point(size = 6) +
    geom_col(width = 0.1) +
    geom_text(aes(label = Probability |> round(2)), colour = "black", size = 3) +
    # coord_flip() +
    scale_fill_brewer(palette = "Spectral", name = "RQ Interval", direction = -1) +
    scale_colour_brewer(palette = "Spectral", name = "RQ Interval", direction = -1) +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 5)) +
    facet_grid(rows = vars(API_Name), cols = vars(county)) +
    labs(x = "RQ Interval", y = "Probability", title = "2020, Current WWT") +
    theme_bw()

RQ_Distribts_by_Year_Growth


# What about a line graph?
line_graph <- Hugin_Data_Output_Tall_Labelled |> 
    filter(WWT_Scenario  == "Current",
           API_Name %notin% c("Estrogens", "Analgesics")) |> 
    mutate(Year_and_Population_Growth = str_remove(Year_and_Population_Growth, " &")) |>
    ggplot(aes(y = Probability, x = fct_inorder(Risk_Bin), colour = Year_and_Population_Growth, group = Year_and_Population_Growth)) +
    geom_line(linewidth = 0.8, aes(linetype = Year_and_Population_Growth)) +
    facet_grid(rows = vars(API_Name), cols = vars(county)) +
    theme_bw() +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    labs(x = "Risk Interval", y = "Probability") +
    guides(guide_legend(title = "Population Growth & Year Scenario"))

line_graph

# What about a violin plot?

# violin_plot <- Hugin_Data_Output_Tall_Labelled |> 
#     filter(WWT_Scenario  == "Current") |> 
#     mutate(Year_and_Population_Growth = str_remove(Year_and_Population_Growth, " &") |> factor(levels = c("2020 None", "2050 Low", "2050 Main", "2050 High"))) |>
#     mutate(negative_probability = Probability * -1) |>
#     pivot_longer(cols = c(Probability, negative_probability), values_to = "probability", names_to = "prob_direction") |> 
#     ggplot(aes(y = fct_inorder(Risk_Bin), x = probability, group = prob_direction), fill = Year_and_Population_Growth) +
#     geom_area() +
#     scale_x_discrete(limits)
#     facet_grid(cols = vars(API_Name, Year_and_Population_Growth))
# violin_plot

# What if I want to put it in a powerpoint presentation?

RQ_Distribts_by_Year_Growth_landscape <- Hugin_Data_Output_Tall_Labelled |> 
    filter(WWT_Scenario  == "Current", 
           API_Name %notin% c("Estrogens", "Painkillers"),
           Risk_Bin %notin% c("true", "false")) |> 
    mutate(Year_and_Population_Growth = str_remove(Year_and_Population_Growth, " &")) |> 
    ggplot(mapping = aes(x = fct_inorder(Year_and_Population_Growth), y = Probability, fill = Risk_Bin)) +
    geom_col() +
    scale_fill_brewer(palette = "Spectral", name = "RQ Interval", direction = -1) +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 5)) +
    facet_grid(cols = vars(API_Name), rows = vars(county)) +
    labs(x = "Year", y = "Probability") +
    theme_bw() +
    theme(text = element_text(size = 16))

RQ_Distribts_by_Year_Growth_landscape