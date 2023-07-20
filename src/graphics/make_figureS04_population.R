# Graph out SSB's population projections, and how I discretise them

Norway_Population_Year_Scen <- Norway_Population_Year |> mutate(Scenario = "Historical Measurements")

proj_for_graph <- Norway_Population_Projections_21C |> select(-Pop_over_2020) |> 
    add_row(Norway_Population_Year_Scen) |> 
    mutate(Scenario = factor(Scenario,
                                  levels = c("Historical Measurements",
                                             "Low national growth (LLL)",
                                             "Main alternative (MMM)",
                                             "High national growth (HHH)")),
           Population_mil = Population / 1e6)

population_continuous_graph <- ggplot(data = proj_for_graph,
           mapping = aes(x = Year, y = Population_mil, colour = Scenario)) +
    scale_colour_manual(values = c("black", "red", "green", "blue")) +
    geom_line() +
    geom_point() +
        theme_bw() +
    labs(x = "Year",
         y = "Population (mil)",
         title = "(a) Statistics Norway Measured and Projected Population, Mainland Norway")

Norway_County_Population_Disc <- Norway_County_General_2020 |> filter(exemplar) |>
    mutate(County_Name = str_glue("{County_Name} ({urb_quantile})")) |> 
    select(County_Name) |> 
    crossing(Scenario = factor(levels = c("2050 Low growth",
                                          "2050 Main",
                                          "2050 High growth")),
             Year = c(2020, 2050)) |> 
    mutate(Population = c(0.2, 0.2, 0.2, 0.2, 0.2, 0.4,
                          0.4, 0.4, 0.4, 0.6, 0.4, 0.6,
                          1.2, 1.2, 1.2, 1.4, 1.2, 1.6))

 
population_discrete_graph <-  ggplot(data = Norway_County_Population_Disc,
           mapping = aes(x = Year, y = Population, colour = Scenario, shape = County_Name)) +
    scale_colour_manual(values = c("red", "green", "blue")) +
    geom_line(aes(linetype = Scenario)) +
    geom_point(size = 2) +
    theme_bw() +
    scale_x_continuous(breaks = c(2020, 2050)) +
    labs(x = "Year",
         y = "Discretised Population (mil)",
         title = "(b) Discretised Predicted County Populations, Based on Statistics Norway Whole Country Predictions") +
    guides(shape = guide_legend("County"))

# YAH: is this really how you want to scale year?

S1_population_graphs <- plot_grid(population_continuous_graph,
                                  population_discrete_graph,
                                  nrow = 2,
                                  align = "v")
