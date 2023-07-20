# Graph the normal distributions of the three sets of APIs
# Run API_sales_LM.R first

# Graphical depictions of Normal Distributions

# Light APIs
low_API_normal_distributions <- ggplot(data = data.frame(x = c(-0.005, 0.005)), aes(x)) +
    # EE2 2020
    stat_function(fun = dnorm, n = 1000, 
                  args = list(mean = 0.000556, sd = 0.0000224), 
                  aes(colour = "ethinylestradiol", linetype = "2020")) +
    # EE2 2050
    stat_function(fun = dnorm, n = 1000, 
                  args = list(mean = 0.00129, sd = 0.0000753), 
                  aes(colour = "ethinylestradiol", linetype = "2050")) +
    # Estradiol 2020
    stat_function(fun = dnorm, n = 1000, 
                  args = list(mean = 0.00262, sd = 0.000215), 
                  aes(colour = "estradiol", linetype = "2020")) +
    # Estradiol 2050
    stat_function(fun = dnorm, n = 1000, 
                  args = list(mean = -0.000211, sd = 0.000723), 
                  aes(colour = "estradiol", linetype = "2050")) +
    scale_colour_manual(values = c("magenta", "darkorchid"), 
                        labels = c("ethinylestradiol", "estradiol"), 
                        name = "API Name") +
    scale_linetype_manual(values = c(1, 2), 
                          labels = c(2020, 2050), 
                          name = "Year Predicted") +
    scale_y_continuous(breaks = NULL) +
    theme_bw() +
    labs(x = "Sales per capita (g)", 
         y = "",
         title = "(a) Predicted Normal Distributions of Ethinylestradiol and Estradiol Sales (g)")

# Medium APIs
medium_API_normal_distributions <- ggplot(data = data.frame(x = c(1e-3, 1.5)), aes(x)) +
    # ciprofloxacin 2020
    stat_function(fun = dnorm, n = 1000, 
                  args = list(mean = 2.476152e-01, sd = 2.727552e-02), 
                  aes(colour = "ciprofloxacin", linetype = "2020")) +
    # ciprofloxacin 2050
    stat_function(fun = dnorm, n = 1000, 
                  args = list(mean = 5.184610e-01, sd = 9.181413e-02), 
                  aes(colour = "ciprofloxacin", linetype = "2050")) +
    # diclofenac 2020
    stat_function(fun = dnorm, 
                  n = 1000, args = list(mean = 5.282533e-01, sd = 3.493906e-02), 
                  aes(colour = "diclofenac", linetype = "2020")) +
    # diclofenac 2050
    stat_function(fun = dnorm, n = 1000, 
                  args = list(mean = 9.965102e-01, sd = 1.176109e-01), 
                  aes(colour = "diclofenac", linetype = "2050")) +
    scale_colour_manual(values = c("mediumpurple1", "slateblue4"), 
                        labels = c("ciprofloxacin", "diclofenac"), 
                        name = "API Name") +
    scale_linetype_manual(values = c(1, 2), 
                          labels = c(2020, 2050), 
                          name = "Year Predicted") +
    scale_y_continuous(breaks = NULL) +
    theme_bw() +
    labs(x = "Sales per capita (g)", 
         y = "", 
         title = "(b) Predicted Normal Distributions of Ciprofloxacin and Diclofenac Sales (g)")

# Heavy APIs
high_API_normal_distributions <- ggplot(data = data.frame(x = c(0, 130)), aes(x)) +
    # ibuprofen 2020
    stat_function(fun = dnorm, n = 1000, 
                  args = list(mean = 9.316434e+00, sd = 5.286413e-01), 
                  aes(colour = "ibuprofen", linetype = "2020")) +
    # ibuprofen 2050
    stat_function(fun = dnorm, n = 1000, 
                  args = list(mean = 1.752382e+01, sd = 1.779498e+00), 
                  aes(colour = "ibuprofen", linetype = "2050")) +
    # paracetamol 2020
    stat_function(fun = dnorm, n = 1000, 
                  args = list(mean = 5.423200e+01, sd = 8.610357e-01), 
                  aes(colour = "paracetamol", linetype = "2020")) +
    # paracetamol 2050
    stat_function(fun = dnorm, n = 1000, 
                  args = list(mean = 1.027457e+02, sd = 2.898396e+00), 
                  aes(colour = "paracetamol", linetype = "2050")) +
    scale_colour_manual(values = c("dodgerblue1", "steelblue4"), 
                        labels = c("ibuprofen", "paracetamol"), 
                        name = "API Name") +
    scale_linetype_manual(values = c(1, 2), 
                          labels = c(2020, 2050), 
                          name = "Year Predicted") +
    guides(colour = guide_legend(order = 1),
           linetype = guide_legend(order = 2)) +
    scale_y_continuous(breaks = NULL) +
    theme_bw() +
    labs(x = "Sales per capita (g)",
         y = "",
         title = "(c) Predicted Normal Distributions of Ibuprofen and Paracetamol Sales (g)")

all_API_normal_distributions <- cowplot::plot_grid(low_API_normal_distributions,
                                                   medium_API_normal_distributions,
                                                   high_API_normal_distributions, 
                                                   nrow = 3,
                                                   align = "h")

all_API_normal_distributions
