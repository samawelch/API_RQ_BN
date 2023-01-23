# Hugin has done its thing, so let's import the data
Hugin_Data_Output <- read_csv(file = "Data/Hugin/Hugin_to_R_datafile.csv",
                              show_col_types = FALSE)

# # Note the threshold used
# Hugin_Threshhold <-  unique(Hugin_Data_Output$PRQ_threshold)

# Hugin's many output interval columns need pivoting to tall data
Hugin_Data_Output_Tall <- Hugin_Data_Output %>% 
    pivot_longer(cols = 8:67,
                 names_to = "Risk_Bin_String",
                 values_to = "Probability") %>% 
    mutate(Risk_Type = str_remove(Risk_Bin_String, pattern = "_[^_]+$") %>% 
               str_remove(pattern = "P\\("),
           API_Name = str_extract(Risk_Bin_String, pattern = "(?<=\\_)([[:alpha:]]*?)(?=\\=)"),
           Risk_Bin = str_extract(Risk_Bin_String, pattern = "(?<==).[a-zA-Z0-9-]+"),
           API_Name = fct_relevel(API_Name, c("estradiol", "ethinylestradiol", "ciprofloxacin", 
                                              "diclofenac", "ibuprofen", "paracetamol", 
                                              "Estrogens", "Painkillers", "AllAPI"))) %>% 
    select(-Risk_Bin_String, -c(2:7)) %>% 
    relocate(Probability, .after = last_col())

scenario_number_labels = tibble(county = c("Rural", "Semi-Urban", "Urban")) %>% 
    crossing(Year_and_Population_Growth = fct_inorder(c("2020 & None", "2050 & Low", 
                                                        "2050 & Main", "2050 & High")),
             WWT_Scenario = fct_inorder(c("Current", "Secondary or better", "Best (all tertiary)"))) %>% 
    mutate(Scenario_Number = row_number()) %>% 
    relocate(Scenario_Number, 1)

# When was the dataset last updated?
Hugin_Output_Last_Updated <- file.info("Data/Hugin/Hugin_to_R_datafile.csv")$mtime

Hugin_Data_Output_Tall_Labelled <- Hugin_Data_Output_Tall %>% 
    left_join(scenario_number_labels, by = c("scenario_number" = "Scenario_Number")) %>% 
    relocate(county, Year_and_Population_Growth, WWT_Scenario, .after = scenario_number)