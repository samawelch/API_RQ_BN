scenario_facet_labeller <- as_labeller(c(`1` = "Rural, 2020, Current WWT",
                                         `2` = "Rural, 2020, Secondary or Better WWT",
                                         `3` = "Rural, 2020, Full Tertiary WWT"))


PGT_n_data <- Hugin_Data_Output_Tall_Labelled %>% 
    filter(scenario_number %in% c(1:3), Risk_Type == "PRQ_GT_n", PGT_Threshold %in% c(100, 500)) %>% 
    mutate(API_n = str_extract(API_Name, pattern = "[0-9]") %>% as.numeric())

threshold_bars_100 <- PGT_n_data %>% 
    filter(PGT_Threshold == 100) %>% 
    ggplot(aes(x = API_n, y = Probability)) +
    geom_col(fill = "#ffc080") +
    scale_x_continuous(breaks = c(1:6)) +
    scale_y_continuous(limits = c(0, 1)) +
    facet_grid(cols = vars(scenario_number), labeller = scenario_facet_labeller) +
    labs(title = "(a) Probability of at least one RQ > 100 with Number of APIs", 
         x = "Number of APIs", 
         y = "P(RQ > 100)") +
    theme_bw()

threshold_bars_500 <- PGT_n_data %>% 
    filter(PGT_Threshold == 500) %>% 
    ggplot(aes(x = API_n, y = Probability)) +
    geom_col(fill = "#ffc080") +
    scale_x_continuous(breaks = c(1:6)) +
    scale_y_continuous(limits = c(0, 1)) +
    facet_grid(cols = vars(scenario_number), labeller = scenario_facet_labeller) +
    labs(title = "(b) Probability of at least one RQ > 500 with Number of APIs", 
         x = "Number of APIs", 
         y = "P(RQ > 500)") +
    theme_bw()

sum_RQ_bars <- Hugin_Data_Output_Tall_Labelled %>% 
    filter(scenario_number %in% c(1:3), Risk_Type == "API_RQ_FW", PGT_Threshold == 100) %>% 
    group_by(scenario_number, API_Name) %>%
    mutate(Risk_Bin_Mean = case_when(Risk_Bin == "0-1" ~ 0.5,
                                     Risk_Bin == "1-10" ~ 5.5,
                                     Risk_Bin == "10-100" ~ 55,
                                     Risk_Bin == "100-1000" ~ 550,
                                     Risk_Bin == "1000-10000" ~ 5500,
                                     Risk_Bin == "10000-inf" ~ 55000),
           API_n = case_when(API_Name == "paracetamol" ~ 1,
                             API_Name == "ibuprofen" ~ 2,
                             API_Name == "diclofenac" ~ 3,
                             API_Name == "ciprofloxacin" ~ 5,
                             API_Name == "ethinylestradiol" ~ 4,
                             API_Name == "estradiol" ~ 6)) %>% 
    summarise(Average_RQ = sum(Risk_Bin_Mean * Probability), API_n) %>% 
    ggplot(aes(x = API_n, y = Average_RQ)) +
    geom_col(fill = "#ffc000") +
    scale_x_continuous(breaks = c(1:6)) +
    facet_grid(cols = vars(scenario_number), labeller = scenario_facet_labeller) +
    labs(title = "(c) Sum of Mean RQs", 
         x = "Number of APIs", 
         y = "Σ Mean RQs") +
    theme_bw()

combined_join_comparison_bars <- plot_grid(sum_RQ_bars,
                                           threshold_bars_100, 
                                           threshold_bars_500,
                                           nrow = 3, 
                                           align = "v")

combined_join_comparison_bars