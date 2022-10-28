# Import Norwegian Institute for Public Health Wholesale Drug Database data
# censored/summarised to the API level, for 8 APIs, 1999 - 2018

API_sales_weights_1999_2018 <- read_csv(file = "data/raw/API_sales_weights_1999_2018.csv",
                                        show_col_types = FALSE)

