# What share of the population does each county have?
total_pop_2020 <- pop_by_county_2020 %>% 
    summarise(sum(Population)) %>% 
    pull()

pop_share_by_county_2020 <- pop_by_county_2020 %>% 
    group_by(County_Name) %>% 
    summarise(County_Name,
              Population,
              Population_Share = round(Population / total_pop_2020, digits = 2))

