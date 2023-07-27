### Average Removal Rates for ~60 APIs
# Dataset from van Dijk et al (2023)
# Available at https://data.mendeley.com/datasets/zsrv92557p/2

API_removal_rates <- read_excel(
  path = "data/raw/Removal_efficiencies_vD.xlsx",
  range = "A1:M59"
) %>%
  transmute(
    JvD_Name = `Substances to be added`,
    InChIKey_string = `InChI Key`,
    primary_removal = `Primary (conventional settelers)`,
    secondary_removal = `Secondary (biological)`,
    tertiary_removal = `Tertiary (e.g. metal salts)`,
    advanced_removal = `Advanced treatment (Chlorination, UV)`,
    ozone_removal = `Ozone`,
    act_carbon_removal = AC
  ) %>%
  distinct() %>%
  pivot_longer(
    cols = 3:8,
    names_to = "treatment",
    values_to = "removal_rate_perc",
  ) |>
  mutate(treatment = factor(treatment, levels = c("primary_removal", "secondary_removal", "tertiary_removal", "advanced_removal", "ozone_removal", "act_carbon_removal")))

API_removal_rates_simple <- API_removal_rates |>
  group_by(treatment) |>
  reframe(med_removal = median(removal_rate_perc, na.rm = TRUE)) |>
  mutate(treatment_merged = case_when(
    treatment == "primary_removal" ~ "primary",
    treatment == "secondary_removal" ~ "secondary_and_tertiary",
    treatment == "tertiary_removal" ~ "secondary_and_tertiary",
    treatment == "advanced_removal" ~ "advanced_etc",
    treatment == "ozone_removal" ~ "advanced_etc",
    treatment == "act_carbon_removal" ~ "advanced_etc"
  ) |> 
    factor(levels = c("primary", "secondary_and_tertiary", "advanced_etc"))) |>
  group_by(treatment_merged) |>
  reframe(max_med_removal = max(med_removal)) 


