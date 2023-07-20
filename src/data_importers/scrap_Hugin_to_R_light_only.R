hugin_output_light <- read_csv("data/Hugin/Hugin_to_R_datafile_light_only.csv")

# Pivot light hugin output
hugin_output_light_tall <- hugin_output_light |> 
    select(-c(2:3)) |> 
    pivot_longer(cols = 2:21,
                 names_to = "Risk_Bin_String",
                 values_to = "Probability") |> 
    mutate(Risk_Type = str_remove(Risk_Bin_String, pattern = "_[^_]+$") %>% 
               str_remove(pattern = "P\\("),
           API_Name = case_when(Risk_Type == "PRQ_GT_n" ~ str_extract(Risk_Bin_String, 
                                                                      pattern = "GT_n_[0-9]"),
                                TRUE ~ str_extract(Risk_Bin_String, 
                                                   pattern = "(?<=\\_)([[:alpha:]]*?)(?=\\=)"))) %>% 
    mutate(API_Name = str_replace(API_Name, "AllAPI", "ΣRQ")) %>% 
    mutate(Risk_Bin = str_extract(Risk_Bin_String, pattern = "(?<==).[a-zA-Z0-9-]+"),
           API_Name = fct_relevel(API_Name, c("ethinylestradiol", "estradiol"))) %>% 
    select(-Risk_Bin_String) %>% 
    relocate(Probability, .after = last_col())

scenario_number_labels = tibble(county = c("Troms & Finnmark (Rural)", "Trøndelag (Semi-Urban)", "Viken (Urban)")) %>% 
    crossing(Year_and_Population_Growth = fct_inorder(c("2020 & None", "2050 & Low", 
                                                        "2050 & Main", "2050 & High")),
             WWT_Scenario = fct_inorder(c("Current", "Secondary or better", "Best (all tertiary)"))) %>% 
    mutate(Scenario_Number = row_number()) %>% 
    relocate(Scenario_Number, 1)

# When was the dataset last updated?
Hugin_Output_Last_Updated <- file.info("Data/Hugin/Hugin_to_R_datafile.csv")$mtime

hugin_output_light_tall_labelled <- hugin_output_light_tall %>% 
    left_join(scenario_number_labels, by = c("scenario_number" = "Scenario_Number")) %>% 
    relocate(county, Year_and_Population_Growth, WWT_Scenario, .after = scenario_number)

# Graphical interpretation
WWTP_RQ_bars <- hugin_output_light_tall_labelled %>% 
           filter(Year_and_Population_Growth == "2050 & Main",
                  WWT_Scenario == "Current") %>% 
    distinct() |> 
    ggplot(aes(x = Risk_Bin, y = Probability, fill = Risk_Bin)) +
    geom_col(position = "dodge") +
    scale_fill_brewer(palette = "Spectral", name = "RQ Interval", direction = -1) +
    scale_x_discrete(labels = function(x) str_wrap(x, width = 10)) +
    facet_grid(rows = vars(API_Name), cols = vars(county)) +
    labs(x = "WWT Scenario (2050)") +
    theme_bw()

WWTP_RQ_bars

