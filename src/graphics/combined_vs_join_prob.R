# Work out what Jannicke suggests, and make it

Hugin_Threshold_Data <- Hugin_Data_Output_Tall %>% 
    filter(Risk_Type == "PRQ_GT", master_year == 2020, master_pop_scenario == "Main", master_WWT_scenario == "Current", Risk_Bin == "true") %>% 
    filter(master_county %in% c("Nordland", "Viken", "Total"))

ggplot(data = Hugin_Threshold_Data,
       aes(y = Probability, x = API_Name)) +
    geom_col(fill = "darkgreen") +
    facet_grid(rows = vars(master_county),
               cols = vars(master_RQ_threshold)) +
    labs(x = "API Group",
         y = "Probability of Threshold Exceedence")

# this is a start, but we need to work out how to transform output Probability distributions
# into the risk of exceedence by number of APIs plot JMO mentioned