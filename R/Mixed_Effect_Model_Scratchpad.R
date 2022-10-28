# Apparently I can used a mixed effect model to generate a distribution of 
# Sales Weights

library(tidyverse)
library(readxl)
library(lme4)

# Here are some variables
# Year
# Population
# API

# Import Data
setwd(dir = "../../burne/OneDrive - NIVA/Projects/Papers/03_Bayesian_Mixture_Toxicity/Data/")
estrogen_example_data <- read_xlsx("Example_Estrogen_Sales.xlsx")

# Preliminary plot?
ggplot(data = estrogen_example_data,
       aes(x = Year, y = Sales_Weight_g, colour = API)) +
  geom_point()

# log10() transform sales weights
# calculate mean()and sd()
# make discrete node in Hugin, set to log normal distribution