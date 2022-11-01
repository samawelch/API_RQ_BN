# Make data files for automated data input/output to Hugin

All_RQ_Interval_Nodes <- append(paste0("API_RQ_FW_", str_to_title(analysed_APIs)), 
                                c("SumRQ_Estrogens", "SumRQ_Antibiotics", 
                                  "SumRQ_Painkillers","SumRQ_Total"))

All_RQ_Boolean_Nodes <- c("PRQ_1_Estrogens", "PRQ_1_Antibiotics", "PRQ_1_Painkillers", "PRQ_1_Total")

Hugin_Data_File <- tibble(master_pop_scenario = as_factor(c("Low", "Main", "High"))) %>% 
    # Use vector recycling via crossing to set up the various scenario combinations easily
    crossing(master_year = c("2020", "2050"),
             master_WWT_scenario = c("Current", "Compliance", "Upgrade"),
             master_county = unlist(county_codes[2])) %>% 
    # Add API node value presets
    add_column(API_light_ethinylestradiol = "ethinylestradiol",
               API_light_estriol = "estriol",
               API_medium_diclofenac = "diclofenac",
               API_medium_ciprofloxacin = "ciprofloxacin",
               API_heavy_paracetamol = "paracetamol",
               API_heavy_ibuprofen = "ibuprofen")
# Add columns to monitor RQ intervals for each API and Sum Node
for (v in 1:length(All_RQ_Interval_Nodes)) {
    Temp_API_Name <- All_RQ_Interval_Nodes[v]
    # print(Temp_API_Name)
    Hugin_Data_File <- Hugin_Data_File %>% 
        add_column(!! glue("P(", "{Temp_API_Name}", "=0-1)") := NA,
                   !! glue("P(", "{Temp_API_Name}", "=1-10)") := NA,
                   !! glue("P(", "{Temp_API_Name}", "=10-100)") := NA,
                   !! glue("P(", "{Temp_API_Name}", "=100-1000)") := NA,
                   !! glue("P(", "{Temp_API_Name}", "=1000-10000)") := NA,
                   !! glue("P(", "{Temp_API_Name}", "=10000-inf)") := NA)
}
# Likewise for each combined probability node
for (v in 1:length(All_RQ_Boolean_Nodes)) {
    Temp_Bool_Name <- All_RQ_Boolean_Nodes[v]
    # print(Temp_Bool_Name)
    Hugin_Data_File <- Hugin_Data_File %>% 
        add_column(!! glue("P(", "{Temp_Bool_Name}", "=true)") := NA,
                   !! glue("P(", "{Temp_Bool_Name}", "=false)") := NA)
}

write_csv(x = Hugin_Data_File, file = "Data/Hugin/R_to_Hugin_datafile.csv", na = "")