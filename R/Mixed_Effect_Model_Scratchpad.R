# Apparently I can used a mixed effect model to generate a distribution of 
# Sales Weights

library(MASS)
library(lme4)
library(tidyverse)
library(readxl)
library(glmm)

# Here are some variables
# Year
# Population
# API

# Import Data
setwd("C:/Users/SAW/OneDrive - NIVA/Projects/Papers/03_Bayesian_Mixture_Toxicity/")
estrogen_example_data <- read_xlsx("Data/Example_Estrogen_Sales.xlsx")

bblocker_example_data <- read_xlsx("Data/Beta_blockers_sales_weights.xlsx")

# Hierarchical data - 
# Clustering by API
# Then a time series relationship between year and weight sold?
# dependent variable = sales


### Estrogen stuff

# Preliminary plot?
ggplot(data = estrogen_example_data,
       aes(x = Sales_Weight_g, fill = API)) +
  geom_histogram(aes(y = ..density..))


# With fitdistrplus
library(fitdistrplus)

estradiol_example_data <- estrogen_example_data %>% 
  filter(API == "estriol")

bad_lnd_estradiol <- fitdist(estrogen_example_data$Sales_Weight_g, "lnorm")
summary(bad_lnd_estradiol)
plot(bad_lnd_estradiol)

# glmm from the package "glmm"
require(lme4)

fit <- lmer(log(Sales_Weight_g) ~ -1 + API + (1 | Year), data = estrogen_example_data)
summary(fit)

exp(summary(fit)$coef[,"Estimate"])

plot(fit)

# Standard error = SD / sqrt(n)
# Standard deviation = sqrt(var)
# SE = sqrt(var) / sqrt (n)
# sqrt(var) = SE *  sqrt (n)
# var = (SE * sqrt(n)) ^ 2

(0.1901 * sqrt(5)) ^ 2
# = 0.18069

library(drc)
test <- weibull1(fixed = c(0.044, -0.75, NA, 1.05))
drm()


### BB Stuff

fit_bb <- lmer(log(AmountSold_g) ~ -1 + API_Name + (1 | sYear), data = bblocker_example_data)
summary(fit_bb)

plot(fit_bb)