# Make a set of graphs of predicted sales weights using the lm under different population scenarios. 

LM_Predictions <- LM_Predictions |> left_join(LMs_API |> select(API_Name, weight_class) |> distinct())

figure03_lm_graphs <- ggplot(data = LMs_API, aes(x = Year, y = sales_g_per_capita, colour = API_Name, group = API_Name)) +
    geom_point() +
    geom_smooth(method = "lm") +
    geom_pointrange(data = LM_Predictions, mapping = aes(x = Year, y = Pred, ymin = CI_95_lower, ymax = CI_95_upper)) +
    stat_poly_eq(method = "lm", use_label(c("eq", "R2")),
                 label.x = 0.75,
                 label.y = c(0.8, 0.9, 0.8, 0.9, 0.8, 0.9)) +
    facet_grid(rows = vars(weight_class |> fct_relevel("light", "medium", "heavy")), scales = "free") +
    labs(x = "Years after 2000",
         y = "API Sales per Capita (g)") +
    theme_bw() +
    theme(legend.position = "bottom", 
          legend.box = "vertical", 
          legend.margin = margin(),
          legend.text = element_text(size = 11)) +
    guides(fill = guide_legend(nrow = 2, byrow = TRUE),
           shape = guide_legend(nrow = 2, byrow = TRUE))

figure03_lm_graphs
