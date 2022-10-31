# Fit a linear model to explain (and predict) API sales weight (kg) by population (mil) and year

# Set approximate weight sales classes: Light (0-100 kg), Medium (100 - 10000 kg), Heavy (10000 - 1000000 kg)
API_sales_by_population <- 
    API_sales_weights_1999_2018 %>% left_join(y = Norway_Population_Year, by = c("Year")) %>% 
    mutate(weight_class = case_when(pmax(Total_Sold_kg) <= 100 ~ "light",
                                    pmax(Total_Sold_kg) <= 10000 ~ "medium",
                                    pmax(Total_Sold_kg) <= 10000000 ~ "heavy"))

# Linear Model: API ~ Population + Year
LMs_API <- API_sales_by_population %>% 
    mutate(Population_mil = Population / 1e6) %>% 
    filter(Year != 2019) %>% 
    group_by(API_Name) %>% 
    summarise(lm_intercept_kg = coef(lm(Total_Sold_kg/Population_mil ~ Year))[[1]],
              lm_coef_kg_per_mperson_per_year = coef(lm(Total_Sold_kg/Population_mil ~ Year))[[2]],
              weight_class) %>% 
    distinct() %>% 
    # Pop PNECs on the end
    left_join(API_PNECs, by = "API_Name")


