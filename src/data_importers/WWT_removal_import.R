### Average Removal Rates for ~60 APIs
# Unpublished dataset from Joanke van Dijk
API_removal_rates <- read_excel(path = "data/raw//Removal_efficiencies_JvD.xlsx", 
                                range = "A1:M59") %>% 
    transmute(InChIKey_string = `InChI Key`,
              primary_removal = `Primary (conventional settelers)`,
              secondary_removal = `Secondary (biological)`,
              tertiary_removal = `Tertiary (e.g. metal salts)`,
              advanced_removal = `Advanced treatment (Chlorination, UV)`,
              ozone_removal = `Ozone`,
              activated_carbon_removal = AC) %>% 
    distinct() %>% 
    pivot_longer(cols = 2:7, 
                 names_to = "treatment",
                 values_to = "removal_rate_perc") 

API_removal_rates <- API_removal_rates %>% add_row(
# We'll reuse JvD's assumption that APIs without removal data will be removed
# at the average rate  
    API_removal_rates %>% 
    group_by(treatment) %>% 
    summarise(removal_rate_perc = mean(removal_rate_perc, na.rm = TRUE),
              treatment,
              InChIKey_string = "mean") %>% 
        distinct()
    )