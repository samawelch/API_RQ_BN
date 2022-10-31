# Merge data for access to large and small WWTP in Norway 2020, by county
# Convert Norwegian names to English/EU classes, based on WWT_definitions_Norway

wwtp_by_county_2020 <- large_wwtp_by_county_2020 %>% 
    pivot_longer(cols = 1:7, names_to = "treatment", values_to = "population") %>% 
    mutate(size = "large") %>% 
    add_row(
        small_wwtp_by_county_2020 %>% 
            pivot_longer(cols = 1:15, names_to = "treatment", values_to = "population") %>% 
            mutate(size = "small")
    ) %>% 
    left_join(WWT_definitions_Norway %>% select(Name_EN, Class_EU), by = c("treatment" = "Name_EN"))

# How well do WWTP numbers and actual populations add up?
wwtp_by_county_2020 %>% 
    filter(treatment == "total") %>% 
    group_by(County_Name) %>% 
    summarise(sum(population), County_Code) %>% 
    distinct() %>% 
    left_join(y = pop_by_county_2020, by = "County_Code") %>% 
    summarise(`sum(population)` / Population)
# Pretty close, +- 5%, except for Troms & Finnmark, which is 15% higher than actual pop

# In any case, we can now characterise the proportions of different treatment levels in each County
wwt_share_by_county_2020 <- 
    wwtp_by_county_2020 %>% 
    filter(treatment != "total") %>% 
    group_by(County_Name, Class_EU) %>% 
    summarise(County_Name,
              County_Code,
              population = sum(population, na.rm = TRUE)) %>% 
    distinct() %>% 
    ungroup() %>% 
    group_by(County_Name) %>% 
    mutate(wwt_pop_share = round(population / sum(population), digits = 2))
