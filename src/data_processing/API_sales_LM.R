# Fit a linear model to explain (and predict) API sales weight (kg) by population (mil) and year

# Set approximate weight sales classes: Light (0-100 kg), Medium (100 - 10000 kg), Heavy (10000 - 1000000 kg)
API_sales_by_population <- 
    API_sales_weights_1999_2018 %>% left_join(y = Norway_Population_Year, by = c("Year")) %>% 
    mutate(weight_class = case_when(pmax(Total_Sold_kg) <= 100 ~ "light",
                                    pmax(Total_Sold_kg) <= 10000 ~ "medium",
                                    pmax(Total_Sold_kg) <= 10000000 ~ "heavy"))

# Linear Model: Sales Weight / Population ~ Year
LMs_API <- API_sales_by_population %>% 
    mutate(Population_mil = Population / 1e6) %>% 
    filter(Year != 2019, Year != 1999) %>% 
    group_by(API_Name) %>% 
    mutate(Year = Year - 2000)

LM_parameters <- tibble()

for (x in unique(LMs_API$API_Name)) {
    temp_lm <- lm(data = LMs_API %>% filter(API_Name == x), 
       formula = Total_Sold_kg/Population_mil ~ Year)
    LM_parameters <- bind_rows(LM_parameters, c(API_Name = x, temp_lm$coefficients))
}

LM_parameters <- LM_parameters %>% 
    transmute(API_Name,
              Intercept_kg_per_mpop = as.numeric(`(Intercept)`),
              Coeff_kg_per_mpop_per_year = as.numeric(Year)) %>% 
    # Pop PNECs on the end
    left_join(API_PNECs, by = "API_Name")

LM_parameters



