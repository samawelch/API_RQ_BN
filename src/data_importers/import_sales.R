# Import Norwegian Institute for Public Health Wholesale Drug Database data
# censored/summarised to the API level, for 8 APIs, 1999 - 2018

API_sales_weights_1999_2018 <- read_csv(file = "data/raw/API_sales_weights_1999_2018.csv",
                                        show_col_types = FALSE)

# Filter to the 6 APIs used in the Bayesian Network
analysed_APIs <- c("estradiol", "ethinylestradiol", "diclofenac", 
                   "ibuprofen", "paracetamol", "ciprofloxacin")
API_sales_weights_1999_2018 <- API_sales_weights_1999_2018 %>% 
    filter(API_Name %in% analysed_APIs)