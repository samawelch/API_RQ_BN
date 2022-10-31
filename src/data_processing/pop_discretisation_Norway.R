# Discretisation Norwegian population in the next highest 0.5 million, in imitation of what has been
# performed manually in Hugin 
Norway_Pop_Discretisation <- Norway_Population_Year %>% 
    transmute(Year,
              Pop_mil = Population / 1e6,
              Scenario = "Historic") %>% 
    add_row(Norway_Population_Projections_21C %>% transmute(Year,
                                                            Pop_mil = Population / 1e6,
                                                            Scenario)) %>% 
    filter(Year <= 2050) %>% 
    # Round to the highest 0.5 pop
    mutate(Pop_mil_disc = plyr::round_any(Pop_mil, 0.5, f = ceiling))