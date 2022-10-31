# Graph population over time, and discretisation thereof, in an admittedly awful plot
ggplot(data = Norway_Pop_Discretisation %>% filter(Year >= 2000), 
       mapping = aes(x = Year,
                     y = Pop_mil,
                     colour = Scenario)) +
    geom_point() +
    geom_line(aes(y = Pop_mil_disc)) +
    scale_colour_discrete(limits = c("Historic",
                                     "Low national growth (LLL)",
                                     "Main alternative (MMM)",
                                     "High national growth (HHH)"))