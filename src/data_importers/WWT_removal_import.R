### Average Removal Rates for ~60 APIs
# Unpublished dataset from Joanke van Dijk
API_removal_rates <- read_excel(path = "data/raw//Removal_efficiencies_JvD.xlsx", 
                                range = "A1:M59") %>% 
    transmute(JvD_Name = `Substances to be added`,
              InChIKey_string = `InChI Key`,
              primary_removal = `Primary (conventional settelers)`,
              secondary_removal = `Secondary (biological)`,
              tertiary_removal = `Tertiary (e.g. metal salts)`,
              advanced_removal = `Advanced treatment (Chlorination, UV)`,
              ozone_removal = `Ozone`,
              activated_carbon_removal = AC) %>% 
    distinct() %>% 
    pivot_longer(cols = 3:7, 
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

# Per a suggestion, what if we use 0, then the median removal rates for 1ary/2&3ary, and best?
API_removal_rates_simple <- API_removal_rates %>% 
    mutate(treatment = case_when(treatment %in% c("secondary_removal", "tertiary_removal") ~ "sec_tert_removal",
                                 TRUE ~ treatment)) %>% 
    group_by(treatment)
    
API_removal_rates_simple_summary <- API_removal_rates_simple %>% 
    summarise(med_removal = median(removal_rate_perc, na.rm = TRUE)) %>% 
    add_row(treatment = "best", med_removal = max(API_removal_rates_simple$removal_rate_perc))