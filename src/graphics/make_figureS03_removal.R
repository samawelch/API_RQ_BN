# plot removal rates by treatment level
vD_API_removal_boxplot <- ggplot(data = API_removal_rates |> filter(!is.na(removal_rate_perc)), 
                                 aes(x = treatment, 
                                     y = removal_rate_perc)) +
  geom_boxplot() +
  stat_n_text() +
  scale_x_discrete(
    labels = c("Primary", "Secondary", "Tertiary", "Advanced", "Ozone", "Activated Carbon"),
    name = "Treatment Level"
  ) +
  labs(y = "Removal Rate (%)") +
  theme_minimal()

# plot median values we used...
BN_API_removal_bars <- ggplot(data = API_removal_rates_simple, 
                              aes(x = treatment_merged, 
                                  y = max_med_removal)) +
  geom_col(colour = "black", fill = "white") +
  scale_x_discrete(
    limits = c("primary", "secondary_and_tertiary", "advanced_etc"),
    labels = c("Primary", "Secondary & Tertiary", "Advanced/Ozone/AC"),
    name = "Merged Treatment Levels"
  ) +
  scale_y_continuous(limits = c(-10, 100)) +
  labs(y = "Maximum of Median Removal Rates") +
  theme_minimal()


figureS03_removal <- plot_grid(vD_API_removal_boxplot, BN_API_removal_bars, align = "h", nrow = 1, labels = "auto")