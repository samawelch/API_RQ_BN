# Make a set of graphs of predicted sales weights using the lm under different populatio scenarios. 

# Recalculate sales weights from the LM for comparison
Sales_Projections_21C <- 
    crossing(LM_parameters, Norway_Pop_Discretisation) %>% 
    mutate(Year = Year - 2000) %>% 
    mutate(Sales_Proj_kg = (Year * Coeff_kg_per_mpop_per_year + Intercept_kg_per_mpop) 
           * Pop_mil_disc) %>% 
    filter(Year %in% c(10, 20, 30, 40, 50)) 


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
    filter(Year != 2019, Year != 1999) %>% 
    mutate(API_Name = fct(API_Name, levels = c("ethinylestradiol", "ciprofloxacin", "ibuprofen",
                                               "estradiol", "diclofenac", "paracetamol")))

figure03_lm_graphs <- ggplot(data = Sales_Projections_Records %>% filter(Scenario != "Measured"),
       mapping = aes(x = Year, 
                     y = pmax(0, Total_Sold_kg),
                     colour = Scenario,
                     shape = Scenario)) + 
    geom_point(size = 1, stroke = 1.3) +
    geom_point(data = Sales_Projections_Records %>% 
                   filter(Scenario == "Measured") %>% 
                   mutate(Year = Year - 2000),
            size = 1) + 
    scale_shape_manual(values = c("Measured" = 16,
                                  "Historic" = 4,
                                  "High national growth (HHH)" = 1,
                                  "Main alternative (MMM)" = 1,
                                  "Low national growth (LLL)" = 1),
                       limits = c("Measured",
                                  "Historic",
                                  "High national growth (HHH)",
                                  "Main alternative (MMM)",
                                  "Low national growth (LLL)")) +
    scale_color_brewer(palette = "Set1",
                       limits = c("Measured",
                                     "Historic",
                                     "High national growth (HHH)",
                                     "Main alternative (MMM)",
                                     "Low national growth (LLL)")) +
    scale_y_continuous(limits = c(0, NA)) +
    scale_x_continuous(breaks = c(0, 10, 20, 30, 40, 50)) +
    facet_wrap(facets = vars(API_Name), scales = "free") +
    labs(x = "Years After 2000", y = "Total Sold (kg)") +
    theme_bw() +
    theme(legend.position = "bottom", 
          legend.box = "vertical", 
          legend.margin = margin(),
          legend.text = element_text(size = 11)) +
    guides(fill = guide_legend(nrow = 2, byrow = TRUE),
           shape = guide_legend(nrow = 2, byrow = TRUE))

figure03_lm_graphs
