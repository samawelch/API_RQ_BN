# Fit a linear model to explain (and predict) API sales weight (kg) by population (mil) and year

# Set approximate weight sales classes: Light (0-100 kg), Medium (100 - 10000 kg), Heavy (10000 - 1000000 kg)
API_sales_by_population <-
  API_sales_weights_1999_2018 %>%
  left_join(y = Norway_Population_Year, by = c("Year")) %>%
  mutate(weight_class = case_when(
    pmax(Total_Sold_kg) <= 100 ~ "light",
    pmax(Total_Sold_kg) <= 10000 ~ "medium",
    pmax(Total_Sold_kg) <= 10000000 ~ "heavy"
  ))

# Linear Model: Sales Weight / Population ~ Year
LMs_API <- API_sales_by_population %>%
  mutate(Population_mil = Population / 1e6) %>%
  filter(Year != 2019, Year != 1999) %>%
  group_by(API_Name) %>%
  mutate(
    Year = Year - 2000,
    sales_g_per_capita = (Total_Sold_kg / Population) * 1000
  )

LM_parameters <- tibble()

for (x in unique(LMs_API$API_Name)) {
  temp_lm <- lm(
    data = LMs_API %>% filter(API_Name == x),
    formula = sales_g_per_capita ~ Year
  )
  # Summary objects for easier extraction of coefficients
  temp_lm_summary <- summary(temp_lm)
  temp_lm_anova <- anova(temp_lm)

  # Predict per-capita sales for 2020 & 2050 from the lm
  temp_lm_prediction <- predict.lm(temp_lm, tibble(Year = c(20, 50)), se.fit = TRUE)

  LM_parameters <- bind_rows(LM_parameters, c(
    API_Name = x,
    temp_lm$coefficients,
    R_squared = temp_lm_summary$r.squared,
    RSE = temp_lm_summary$sigma,
    F_statistic = temp_lm_anova$`F value`[1],
    P_greaterthan_F = temp_lm_anova$`Pr(>F)`[1],
    df = temp_lm$df.residual,
    Pred_2020 = temp_lm_prediction$fit[1] |> unname(),
    SE_2020 = temp_lm_prediction$se.fit[1] |> unname(),
    Pred_2050 = temp_lm_prediction$fit[2] |> unname(),
    SE_2050 = temp_lm_prediction$se.fit[2] |> unname()
  ))
}

LM_parameters <- LM_parameters %>%
  mutate(
    Intercept_g_per_capita = `(Intercept)`,
    Coeff_g_per_capita = Year
  ) |>
  select(-Year, -`(Intercept)`) |>
  # Pop PNECs on the end
  left_join(API_PNECs, by = "API_Name") |>
  # Make sure everything's a number
  mutate(across(R_squared:PNEC_ugL, as.numeric))


LM_parameters |> write_csv(file = "output/tables/tab_03_lm_params.csv")

# Inspect visually
LM_Predictions <- LM_parameters |>
  select(API_Name, Pred_2020, SE_2020, Pred_2050, SE_2050) |>
  pivot_longer(cols = c(Pred_2020, SE_2020, Pred_2050, SE_2050)) |>
  mutate(
    Year = str_extract(name, "[0-9]{4}") |> as.numeric() |> (`-`)(2000),
    name = str_remove(name, "_[0-9]{4}")
  ) |>
  pivot_wider(values_from = value, names_from = name, values_fn = as.numeric) |>
  # convert SE to 95% CIs
  mutate(
    CI_95_upper = Pred + 1.96 * SE,
    CI_95_lower = Pred - 1.96 * SE
  ) |>
  distinct()
