# Make a set of graphs of predicted sales weights using the lm under different populatio scenarios. 

# Recalculate sales weights from the LM for comparison
Sales_Projections_21C <- 
    crossing(LMs_API, Norway_Pop_Discretisation) %>% 
    mutate(Sales_Proj_kg = (Year * lm_coef_kg_per_mperson_per_year + lm_intercept_kg) 
           * Pop_mil_disc) %>% 
    filter(Year %in% c(2010, 2020, 2030, 2040, 2050))

# Join projections and records together to plot on one graph
Sales_Projections_Records <- Sales_Projections_21C %>% 
    transmute(API_Name,
              Total_Sold_kg = Sales_Proj_kg,
              Scenario,
              Year) %>% 
    add_row(API_sales_weights_1999_2018 %>% transmute(API_Name,
                                                      Year,
                                                      Total_Sold_kg,
                                                      Scenario = "Measured")) %>% 
    filter(Year != 2019)

ggplot(data = Sales_Projections_Records %>% filter(Scenario != "Measured"),
       mapping = aes(x = Year, 
                     y = pmax(0, Total_Sold_kg),
                     colour = Scenario,
                     shape = Scenario)) + 
    geom_point(size = 1, stroke = 1.3) +
    geom_point(data = Sales_Projections_Records %>% filter(Scenario == "Measured"),
               colour = "black", size = 1) + 
    scale_shape_manual(values = c("Measured" = 16,
                                  "Historic" = 4,
                                  "High national growth (HHH)" = 4,
                                  "Main alternative (MMM)" = 4,
                                  "Low national growth (LLL)" = 4)) +
    scale_colour_discrete(limits = c("Measured",
                                     "Historic",
                                     "High national growth (HHH)",
                                     "Main alternative (MMM)",
                                     "Low national growth (LLL)")) +
    scale_y_continuous(limits = c(0, NA)) +
    facet_wrap(facets = vars(API_Name), scales = "free") +
    labs(x = "Year", y = "Total Sold (kg)")