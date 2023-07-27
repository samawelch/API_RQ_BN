# Read in a dataframe of API PNECs from various sources

API_PNECs <- read_excel(path = "data/raw/API_PNECs.xlsx") %>% 
    transmute(API_Name, PNEC_ugL = Value_ugL_standard)

