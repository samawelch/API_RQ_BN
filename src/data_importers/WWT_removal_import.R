### Average Removal Rates for ~60 APIs
# Unpublished dataset from Joanke van Dijk
API_removal_rates <- read_excel(path = "Data/Removal_efficiencies_JvD.xlsx", 
                                range = "A1:M59") %>% 
    transmute(InChIKey_string = `InChI Key`,
              primary_removal = `Primary (conventional settelers)`,
              secondary_removal = `Secondary (biological)`,
              tertiary_removal = `Tertiary (e.g. metal salts)`,
              advanced_removal = `Advanced treatment (Chlorination, UV)`,
              ozone_removal = `Ozone`,
              activated_carbon_removal = AC) %>% 
    left_join(API_Sales %>% select(API_Name, InChIKey_string), by = "InChIKey_string") %>% 
    distinct() %>% 
    relocate(API_Name) %>% 
    pivot_longer(cols = 3:8, 
                 names_to = "treatment_removal_rate")
# We'll reuse JvD's assumption that APIs without removal data will be removed
# at the average rate  
API_removal_rates_mean <- API_removal_rates %>% 
    group_by(treatment_removal_rate) %>% 
    summarise(mean_removal = mean(value, na.rm = TRUE),
              stdev_removal = sd(value, na.rm = TRUE))