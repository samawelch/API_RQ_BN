# Draw discrete probability distributions (as lines) for 6 APIs across 4 population scenarios
figure04_data <- Hugin_Data_Output_Tall_Labelled |>
  filter(
    WWT_Scenario == "Baseline",
    API_Name %notin% c("Estrogens", "Analgesics")
  ) |>
  mutate(Year_and_Population_Growth = str_remove(Year_and_Population_Growth, " &"))
 
figure04_population <- ggplot(data = figure04_data,
                              aes(y = Probability, 
                                  x = fct_inorder(Risk_Bin), 
                                  colour = fct_inorder(Year_and_Population_Growth),
                                  linetype = fct_inorder(Year_and_Population_Growth), 
                                  group = Year_and_Population_Growth)) +
  geom_step(direction = "mid", 
            linewidth = 1) +
  scale_linetype_manual(
    values = c("solid", "11", "12", "21"),
    labels = c("2020 (No Growth)", "2050 (Low Growth)", "2050 (Main Growth)", "2050 (High Growth)"),
    breaks = c("2020 None", "2050 Low", "2050 Main", "2050 High"),
    name = "Population Growth & Year Scenario") +
  facet_grid(rows = vars(API_Name), 
             cols = vars(county)) +
  theme_minimal() +
  scale_colour_manual(
    values = c("grey", "#0040FF", "#11EE67", "#F8766D"),
    labels = c("2020 (No Growth)", "2050 (Low Growth)", "2050 (Main Growth)", "2050 (High Growth)"),
    breaks = c("2020 None", "2050 Low", "2050 Main", "2050 High"),
    name = "Population Growth & Year Scenario"
  ) +
  theme(axis.text.x = element_text(angle = 90, 
                                   hjust = 1)) +
  theme(legend.position = "bottom") +
  labs(x = "RQ Interval")

figure04_population

# Solid histograms
# figure04_population <- Hugin_Data_Output_Tall_Labelled |>
#     filter(
#         WWT_Scenario == "Baseline",
#         API_Name %notin% c("Estrogens", "Analgesics")
#     ) |>
#     mutate(Year_and_Population_Growth = str_remove(Year_and_Population_Growth, " &")) |>
#     ggplot(aes(y = Probability,
#                x = fct_inorder(Risk_Bin),
#                fill = Year_and_Population_Growth,
#                group = Year_and_Population_Growth, 
#                colour = Year_and_Population_Growth,
#                linetype = Year_and_Population_Growth)) +
#     geom_col(width = 1, 
#              alpha = 0.2, 
#              position = "identity", 
#              linewidth = 0.8) +
#     facet_grid(rows = vars(API_Name), cols = vars(county)) +
#     theme_bw() +
#     scale_fill_manual(
#         values = c("grey", "#0040FF", "#11EE67", "#F8766D"),
#         labels = c("2020 (No Growth)", "2050 (Low Growth)", "2050 (Main Growth)", "2050 (High Growth)"),
#         breaks = c("2020 None", "2050 Low", "2050 Main", "2050 High"),
#         name = "Population Growth & Year Scenario"
#     ) +
#   scale_colour_manual(
#     values = c("grey", "#0040FF", "#11EE67", "#F8766D"),
#     labels = c("2020 (No Growth)", "2050 (Low Growth)", "2050 (Main Growth)", "2050 (High Growth)"),
#     breaks = c("2020 None", "2050 Low", "2050 Main", "2050 High"),
#     name = "Population Growth & Year Scenario"
#   ) +
#   scale_linetype_manual(
#     values = c("solid", "11", "12", "21"),
#     labels = c("2020 (No Growth)", "2050 (Low Growth)", "2050 (Main Growth)", "2050 (High Growth)"),
#     breaks = c("2020 None", "2050 Low", "2050 Main", "2050 High"),
#     name = "Population Growth & Year Scenario") +
#     theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
#     labs(x = "Risk Interval", y = "Probability") +
#     theme(legend.position = "bottom")
# 
# figure04_population
