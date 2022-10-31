# Hugin has done its thing, so let's import the data
Hugin_Data_Output <- read_csv(file = "Data/Hugin/Hugin_to_R_datafile.csv",
                              show_col_types = FALSE) %>% 
    # rename_with(cols = 8:15, ~str_remove(string = ., pattern = "\\[MEAN\\]")) %>% 
    # rename_with(cols = 8:15, ~str_remove_all(string = ., pattern = "\\W"))
    # Need to refactorise population scenarios
    mutate(master_pop_scenario = fct_relevel(master_pop_scenario, c("Low", "Main", "High")),
           master_WWT_scenario = as.ordered(master_WWT_scenario)) %>% 
    select(-c(5:10))

# Hugin's many output interval columns need pivoting to tall data
Hugin_Data_Output_Tall <- Hugin_Data_Output %>% 
    pivot_longer(cols = 5:72,
                 names_to = "Risk_Bin_String",
                 values_to = "Probability") %>% 
    mutate(Risk_Type = str_remove(Risk_Bin_String, pattern = "_[^_]+$") %>% 
               str_remove(pattern = "P\\("),
           API_Name = str_extract(Risk_Bin_String, pattern = "(?<=\\_)([[:alpha:]]*?)(?=\\=)"),
           Risk_Bin = str_extract(Risk_Bin_String, pattern = "(?<==).[a-zA-Z0-9-]+")) %>% 
    select(-Risk_Bin_String) %>% 
    relocate(Probability, .after = last_col())

# When was the dataset last updated?
Hugin_Output_Last_Updated <- file.info("Data/Hugin/Hugin_to_R_datafile.csv")$mtime
