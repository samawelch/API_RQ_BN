# What about estimating individual values (just based on means) for each scenario & API
LM_Predictions
# This is potentially quite complicated to perform, as we don't, for instance, have the population
# scenarios for each county outside of the BN
# I think

# county population estimates
BN_Pop_Factors <- Norway_Population_Projections_21C |>
  filter(Year %in% c(2020, 2050)) |>
  select(Scenario, Year, Pop_over_2020) |>
  add_row(Scenario = "None", Year = 2020, Pop_over_2020 = 1) |>
  mutate(Population_Scenario = factor(Scenario, levels = c(
    "None",
    "Low national growth (LLL)",
    "Main alternative (MMM)",
    "High national growth (HHH)"
  ))) |>
  select(-Scenario)

BN_Counties <- Norway_County_General_2020 |>
  filter(exemplar) |>
  select(County_Name, Population) |>
  mutate(County_Name = factor(County_Name, levels = c("Troms & Finnmark", "Trøndelag", "Viken")))

BN_removal_rates <- read_csv(file = "data/temp/scenario_removal_rates.csv")



BN_County_Pop_Projections <- crossing(BN_Pop_Factors, BN_Counties) |>
  mutate(Population_Projection = Population * Pop_over_2020) |>
  crossing(WWT_Scenario = fct_inorder(c("Baseline", "Partial Upgrade", "Advanced Upgrade"))) |>
  arrange(County_Name, Population_Scenario, WWT_Scenario) |> 
    mutate(Scenario_Number = row_number(),
           Year = Year - 2000) |> left_join(Norway_Wastewater_County_2020, by = ("County" = "County_Name")) |> 
    group_by(County_Name) |> 
    mutate(WW_2020_GL = (Population * Consumption_PPerson_PDay) / 1e6) |> 
    ungroup()

# LM_predictions_wide <- LM_Predictions |> 
#     select(API_Name, Year, Pred) |>
#     pivot_wider(names_from = c(API_Name), values_from = Pred, names_glue = "{API_Name}_per_capita_g")
# 
# API_PNECs_wide <- LM_parameters |> 
#     select(API_Name, PNEC_ugL) |> 
#     pivot_wider(names_from = "API_Name", values_from = PNEC_ugL, names_glue = "{API_Name}_PNEC_ugL")

Deterministic_Node_Calculations <- BN_County_Pop_Projections |> crossing(API_Name = fct_inorder(c("ethinylestradiol",
                                                                                                  "estradiol",
                                                                                                  "ciprofloxacin",
                                                                                                  "diclofenac",
                                                                                                  "ibuprofen",
                                                                                                  "paracetamol"))) |> 
    relocate(Scenario_Number, .before = 1) |> 
    left_join(LM_parameters |> select(API_Name, PNEC_ugL), by = "API_Name") |> 
    left_join(LM_Predictions |>  select(API_Name, Year, Pred), by = c("API_Name", "Year")) |> 
    left_join(BN_removal_rates, by = "Scenario_Number") |> 
    rename(Mean_Sales_per_Capita_g = Pred,
           Population_2020 = Population) |> 
    mutate(Total_Sales_kg = Population_Projection * (Mean_Sales_per_Capita_g / 1000),
           PEC_influent_ugL = Total_Sales_kg / WW_2020_GL,
           PEC_effluent_ugL = PEC_influent_ugL * (1 - API_Removal_Rate),
           PEC_SW_ugL = PEC_effluent_ugL / 10,
           RQ_SW = case_when(PEC_SW_ugL/ PNEC_ugL > 0 ~ PEC_SW_ugL/ PNEC_ugL,
                             TRUE ~ 0))

ggplot(data = Deterministic_Node_Calculations |> filter(WWT_Scenario  == "Baseline"),
       mapping = aes(x = RQ_SW, y = fct_inorder(API_Name), colour = Population_Scenario, shape = Population_Scenario)) +
    geom_point(size = 2) +
    facet_grid(rows = vars(fct_inorder(API_Name)), cols = vars(County_Name), scales = "free_y") +
    theme_bw() +
    scale_x_continuous(breaks = c(0.3, 1, 3, 10, 30, 100, 300, 1000), trans = "log")
           
# YAH: well, these are deterministic values. but now that I have them I'm not sure what to do with them?
    