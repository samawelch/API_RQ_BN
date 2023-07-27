figure06_data <- Hugin_Data_Output_Tall_Labelled |>
  filter(API_Name %notin% c("Analgesics", "Estrogens", "Total")) |>
  group_by(API_Name, county, Year_and_Population_Growth, WWT_Scenario) |>
  mutate(Risk_Bin_Mean = case_when(
    Risk_Bin == "-inf-0" ~ 0,
    Risk_Bin == "0-1" ~ 0.5,
    Risk_Bin == "1-3" ~ 2,
    Risk_Bin == "3-10" ~ 6.5,
    Risk_Bin == "10-30" ~ 20,
    Risk_Bin == "30-100" ~ 65,
    Risk_Bin == "100-300" ~ 200,
    Risk_Bin == "300-1000" ~ 650,
    Risk_Bin == "1000-3000" ~ 2000,
    Risk_Bin == "3000-inf" ~ 6500
  ),
  Year_and_Population_Growth = str_wrap(Year_and_Population_Growth, width = 6)) |>
  reframe(Average_RQ = sum(Risk_Bin_Mean * Probability)) |>
  group_by(API_Name, county, Year_and_Population_Growth, WWT_Scenario)

figure06_summed <- ggplot(
  data = figure06_data,
  aes(
    x = factor(Year_and_Population_Growth, levels = c("2020 &\nNone", "2050 &\nLow", "2050 &\nMain", "2050 &\nHigh")),
    y = Average_RQ,
    fill = API_Name
  )
) +
  scale_fill_brewer(type = "qual", name = "API Name") +
  geom_col() +
  facet_grid(cols = vars(county), rows = vars(WWT_Scenario)) +
  labs(
    x = "Number of APIs",
    y = "Sum of Mean RQs"
  ) +
  theme_bw() +
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank()
  )

figure06_summed
