
# Disc of WWTP share:
wwt_share_by_county_2020_disc <- wwt_share_by_county_2020 %>% 
    mutate(wwt_pop_share_disc = plyr::round_any(wwt_pop_share, 0.25, f = round))
# Check percentages = 100%
wwt_share_by_county_2020_disc %>% group_by(County_Name) %>% 
    summarise(sum(wwt_pop_share_disc))
# total for Norway
wwt_share_by_county_2020_disc %>% 
    group_by(Class_EU) %>% 
    summarise(sum(population)) %>% 
    summarise(`sum(population)` / sum(`sum(population)`))
# Add rows for total to the discretised dataframe

# Scenarios:
# Compliance: all secondary?
# Upgrade: all tertiary

# YAH: Set up levels for scenarios

# generate CPTs for no WWT (%), Primary, Secondary, Tertiary

# How many states should each node have? What values do these states have
WWT_level_states <- wwt_share_by_county_2020_disc %>% 
    group_by(Class_EU) %>% 
    summarise(n_states = n_distinct(wwt_pop_share_disc)) %>% 
    crossing(states = c(0, 0.25, 0.5, 0.75, 1)) %>% 
    group_by(Class_EU) %>% 
    # some intensely ugly code to produce a list of valid discretised states per treatment level
    summarise(n_in_class = row_number(),
              n_states,
              states) %>% 
    filter(n_in_class <= n_states) %>% 
    select(Class_EU, states) %>% 
    # no county has a tertiary level of 0.75, so we swap it for 1 (Oslo)
    mutate(states = case_when((Class_EU == "tertiary" & states == 0.75) ~ 1 ,
                              TRUE ~ states))

# Set up a big dataframe of all node values
all_removal_nodes <- wwt_share_by_county_2020_disc %>%
    select(County_Name, wwt_pop_share_disc, Class_EU) %>%
    crossing(Scenario = factor(levels = c("Current", "Compliance", "Upgrade")),
             # use the WWT_level_states we set earlier to cross w/ relevant levels
             Value = WWT_level_states %>%
                 select(states) %>%
                 pull()) %>%
    mutate(present = as.numeric(wwt_pop_share_disc == Value)) %>% 
    arrange(Class_EU, County_Name, Scenario) %>% 
    pivot_wider(names_from = c("County_Name", "Scenario"), 
                values_from = present, 
                values_fill = 0) %>% 
    filter(wwt_pop_share_disc == Value)

# Set values for compliance and upgrade scenarios

# a big problem RN: setting upgrade scenarios is a bit more complicated than I gave it credit for being
# I think we need to set them earlier up the pipe
all_removal_nodes_scenarios <- all_removal_nodes %>% 
    mutate(across(.cols = contains("Compliance"), ~ case_when(((Class_EU == "secondary" & Value == 1) | 
                                                                  (Class_EU != "secondary" && Value == 0)) ~ 1, 
                                                              TRUE ~ 0)),
           across(.cols = contains("Upgrade"), ~ case_when((Class_EU == "tertiary" & Value == 1) ~ 1, TRUE ~ 0))) %>% 
    arrange(wwt_pop_share_disc)

save_CPT <- function(CPT_dataframe, CPT_save_path){
    # Take the submitted dataframe
    # Remove columns used to format the CPT
    CPT_dataframe_selected <- CPT_dataframe
    
    # Values need decimal points or Hugin won't recognise them
    CPT_dataframe_selected <- CPT_dataframe_selected %>%
        mutate(across(everything(), as.character)) %>% 
        mutate(across(everything(), ~ paste0(., ".0")))  
    
    # Create a text file with HUGIN's preferred table header
    write_lines(x = "CPT", file = CPT_save_path)
    # Then add the CPT
    write.table(x = CPT_dataframe_selected, 
                file = CPT_save_path, 
                append = TRUE, col.names = FALSE, row.names = FALSE,
                sep = ",", quote = FALSE)
}


# Save CPTs for the various levels
# No WWT
save_CPT(CPT_dataframe = all_removal_nodes_scenarios %>% filter(Class_EU == "none") %>% select(-c(1:3)),
         CPT_save_path = "data/Hugin/spatial_county_WWT_0_CPT.txt")

# Primary WWT
save_CPT(CPT_dataframe = all_removal_nodes_scenarios %>% filter(Class_EU == "primary") %>% select(-c(1:3)),
         CPT_save_path = "data/Hugin/spatial_county_WWT_1_CPT.txt")
# Secondary WWT
save_CPT(CPT_dataframe = all_removal_nodes_scenarios %>% filter(Class_EU == "secondary") %>% select(-c(1:3)),
         CPT_save_path = "data/Hugin/spatial_county_WWT_2_CPT.txt")
# Tertiary WWT
save_CPT(CPT_dataframe = all_removal_nodes_scenarios %>% filter(Class_EU == "tertiary") %>% select(-c(1:3)),
         CPT_save_path = "data/Hugin/spatial_county_WWT_3_CPT.txt")