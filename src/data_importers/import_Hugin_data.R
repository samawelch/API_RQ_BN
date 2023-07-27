# Hugin has done its thing, so let's import the data
Hugin_Data_Output <- read_csv(file = "Data/Hugin/Hugin_to_R_datafile.csv",
                              show_col_types = FALSE)


Hugin_Data_Output_Tall <- Hugin_Data_Output %>%
     select(-c(2:7)) %>%
    pivot_longer(cols = 2:61,
                 names_to = "Risk_Bin_String",
                 values_to = "Probability") |> 
        mutate(Risk_Type = str_remove(Risk_Bin_String, pattern = "_[^_]+$") %>%
                           str_remove(pattern = "P\\("),
               API_Name = str_extract(Risk_Bin_String, pattern = "(?<=\\_)([[:alpha:]]*?)(?=\\=)")) %>% 
        mutate(Risk_Bin = str_extract(Risk_Bin_String, pattern = "(?<==).[a-zA-Z0-9-]+"),
               API_Name = fct_relevel(API_Name, c("ethinylestradiol", "estradiol", "ciprofloxacin",
                                                  "diclofenac", "ibuprofen", "paracetamol"))) %>%
        select(-Risk_Bin_String) %>%
        relocate(Probability, .after = last_col())

scenario_number_labels = tibble(county = c("Troms & Finnmark (Rural)", "Trøndelag (Semi-Urban)", "Viken (Urban)")) %>%
    crossing(Year_and_Population_Growth = fct_inorder(c("2020 & None", "2050 & Low",
                                                        "2050 & Main", "2050 & High")),
             WWT_Scenario = fct_inorder(c("Baseline", "Partial Upgrade", "Advanced Upgrade"))) %>%
    mutate(Scenario_Number = row_number()) %>%
    relocate(Scenario_Number, 1)

# When was the dataset last updated?
Hugin_Output_Last_Updated <- file.info("Data/Hugin/Hugin_to_R_datafile.csv")$mtime
Hugin_Output_Last_Updated

Hugin_Data_Output_Tall_Labelled <- Hugin_Data_Output_Tall %>%
    left_join(scenario_number_labels, by = c("scenario_number" = "Scenario_Number")) %>%
    relocate(county, Year_and_Population_Growth, WWT_Scenario, .after = scenario_number)


















### Old code: for thresholds, etc.

# # Note the threshold used
# Hugin_Threshhold <-  unique(Hugin_Data_Output$PRQ_threshold)

# # Hugin's many output interval columns need pivoting to tall data
# Hugin_Data_Output_Tall <- Hugin_Data_Output %>% 
#      select(-c(2:7)) %>% 
#     pivot_longer(cols = 3:62,
#                  names_to = "Risk_Bin_String",
#                  values_to = "Probability") %>% 
#     # please excuse my horrible code
#     mutate(Risk_Type = str_remove(Risk_Bin_String, pattern = "_[^_]+$") %>% 
#                        str_remove(pattern = "P\\("),
#            API_Name = case_when(Risk_Type == "PRQ_GT_n" ~ str_extract(Risk_Bin_String, 
#                                                                       pattern = "GT_n_[0-9]"),
#                                 TRUE ~ str_extract(Risk_Bin_String, 
#                                                    pattern = "(?<=\\_)([[:alpha:]]*?)(?=\\=)"))) %>% 
#     mutate(API_Name = str_replace(API_Name, "AllAPI", "ΣRQ")) %>% 
#     mutate(Risk_Bin = str_extract(Risk_Bin_String, pattern = "(?<==).[a-zA-Z0-9-]+"),
#            API_Name = fct_relevel(API_Name, c("ethinylestradiol", "estradiol", "ciprofloxacin", 
#                                               "diclofenac", "ibuprofen", "paracetamol", 
#                                               "Estrogens", "Painkillers", "ΣRQ", 
#                                               "GT_n_1", "GT_n_2", "GT_n_3", 
#                                               "GT_n_4", "GT_n_5", "GT_n_6"))) %>% 
#     select(-Risk_Bin_String) %>% 
#     relocate(Probability, .after = last_col())
# 
# 
# scenario_number_labels = tibble(county = c("Troms & Finnmark (Rural)", "Trøndelag (Semi-Urban)", "Viken (Urban)")) %>% 
#     crossing(Year_and_Population_Growth = fct_inorder(c("2020 & None", "2050 & Low", 
#                                                         "2050 & Main", "2050 & High")),
#              WWT_Scenario = fct_inorder(c("Current", "Secondary or better", "Best (all tertiary)"))) %>% 
#     mutate(Scenario_Number = row_number()) %>% 
#     relocate(Scenario_Number, 1)
# 
# # When was the dataset last updated?
# Hugin_Output_Last_Updated <- file.info("Data/Hugin/Hugin_to_R_datafile.csv")$mtime
# 
# Hugin_Data_Output_Tall_Labelled <- Hugin_Data_Output_Tall %>% 
#     left_join(scenario_number_labels, by = c("scenario_number" = "Scenario_Number")) %>% 
#     relocate(county, Year_and_Population_Growth, WWT_Scenario, .after = scenario_number)


