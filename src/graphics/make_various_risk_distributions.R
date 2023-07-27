# how can we easily & intuitively compare discrete probability distributions
# answer: we can't

test_data <- Hugin_Data_Output_Tall_Labelled |>
    filter(
        WWT_Scenario == "Baseline",
        API_Name %notin% c("Estrogens", "Analgesics", "Total")
    ) |>
    mutate(Year_and_Population_Growth = str_remove(Year_and_Population_Growth, " &"))


stacked_bars <- ggplot(data = test_data, mapping = aes(x = fct_inorder(Year_and_Population_Growth), y = Probability, fill = fct_inorder(Risk_Bin))) +
    geom_col(position = "stack") +
    scale_fill_brewer(palette = "Spectral", direction = -1) +
     coord_flip() +
    facet_grid(cols = vars(county), rows = vars(API_Name))
stacked_bars
# Difficult to compare, and we can never agree on whether low risk should go at the top or bottom

pies <- ggplot(data = test_data, mapping = aes(x = "", y = Probability, fill = fct_inorder(Risk_Bin))) +
    geom_col() +
    coord_polar("y", start = 0) +
    scale_fill_brewer(palette = "Spectral", direction = -1) +
    facet_grid(cols = vars(county, fct_inorder(Year_and_Population_Growth)), rows  = vars(API_Name)) +
    theme_minimal() +
    theme(axis.text.x = element_blank())
pies
# Also, I think, difficult to compare

# stepped charts?
steps <- ggplot(data = test_data,
           aes(y = Probability, 
               x = fct_inorder(Risk_Bin), 
               colour = fct_inorder(Year_and_Population_Growth),
               linetype = fct_inorder(Year_and_Population_Growth), 
               group = Year_and_Population_Growth)) +
    geom_step(direction = "mid", alpha = 1, linewidth = 1) +
    scale_linetype_manual(
      values = c("solid", "11", "12", "21"),
      labels = c("2020 (No Growth)", "2050 (Low Growth)", "2050 (Main Growth)", "2050 (High Growth)"),
      breaks = c("2020 None", "2050 Low", "2050 Main", "2050 High"),
      name = "Population Growth & Year Scenario") +
    facet_grid(rows = vars(API_Name), cols = vars(county)) +
    theme_minimal() +
    scale_colour_manual(
        values = c("grey", "#0040FF", "#66EE67", "#F8766D"),
        labels = c("2020 (No Growth)", "2050 (Low Growth)", "2050 (Main Growth)", "2050 (High Growth)"),
        breaks = c("2020 None", "2050 Low", "2050 Main", "2050 High"),
        name = "Population Growth & Year Scenario"
    ) +
    theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
    theme(legend.position = "bottom") +
    labs(x = "RQ Interval")
steps
# with new linetypes it's easier to see where distributions overlap
# I think this is my favourite, although I wouldn't call it good.
# + Doesn't use risk-based colour coding, which one of the reviewers didn't seem to like