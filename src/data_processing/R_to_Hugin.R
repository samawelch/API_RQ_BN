# Make data files for automated data input/output to Hugin

All_RQ_Interval_Nodes <- c(paste0("API_RQ_FW_", tolower(analysed_APIs)))
# 
# All_RQ_Boolean_Nodes <- c("PRQ_GT_n_1", "PRQ_GT_n_2", "PRQ_GT_n_3", "PRQ_GT_n_4", "PRQ_GT_n_5", "PRQ_GT_n_6")
# 
# All_Boolean_Thresholds <- c(100, 500, 1000)

Hugin_Data_File <- tibble(scenario_number = 1:36) %>% 
    # Add API node value presets
    add_column(API_low_ethinylestradiol = "ethinylestradiol",
               API_low_estradiol = "estradiol",
               API_medium_diclofenac = "diclofenac",
               API_medium_ciprofloxacin = "ciprofloxacin",
               API_high_paracetamol = "paracetamol",
               API_high_ibuprofen = "ibuprofen")
    # crossing(PGT_Threshold = All_Boolean_Thresholds)
# Add columns to monitor RQ intervals for each API and Sum Node
for (v in 1:length(All_RQ_Interval_Nodes)) {
    Temp_API_Name <- All_RQ_Interval_Nodes[v]
    # print(Temp_API_Name)
    Hugin_Data_File <- Hugin_Data_File %>% 
        add_column(!! glue("P(", "{Temp_API_Name}", "=-inf-0)") := NA,
                   !! glue("P(", "{Temp_API_Name}", "=0-1)") := NA,
                   !! glue("P(", "{Temp_API_Name}", "=1-3)") := NA,
                   !! glue("P(", "{Temp_API_Name}", "=3-10)") := NA,
                   !! glue("P(", "{Temp_API_Name}", "=10-30)") := NA,
                   !! glue("P(", "{Temp_API_Name}", "=30-100)") := NA,
                   !! glue("P(", "{Temp_API_Name}", "=100-300)") := NA,
                   !! glue("P(", "{Temp_API_Name}", "=300-1000)") := NA,
                   !! glue("P(", "{Temp_API_Name}", "=1000-3000)") := NA,
                   !! glue("P(", "{Temp_API_Name}", "=3000-inf)") := NA)
}
# # Likewise for each combined probability node
# for (v in 1:length(All_RQ_Boolean_Nodes)) {
#     Temp_Bool_Name <- All_RQ_Boolean_Nodes[v]
#     # print(Temp_Bool_Name)
#     Hugin_Data_File <- Hugin_Data_File %>% 
#         add_column(!! glue("P(", "{Temp_Bool_Name}", "=true)") := NA)
# }

write_csv(x = Hugin_Data_File, file = "Data/Hugin/R_to_Hugin_datafile.csv", na = "")