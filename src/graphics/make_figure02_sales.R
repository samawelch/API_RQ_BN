# Make a set of graphs of predicted sales weights using the lm under different population scenarios. 

LM_Predictions <- LM_Predictions |> left_join(LMs_API |> select(API_Name, weight_class) |> distinct()) |> 
    mutate(API_Name = factor(API_Name, levels = c("ethinylestradiol", "estradiol","diclofenac", "ciprofloxacin", "paracetamol","ibuprofen"))) |> 
    arrange(API_Name)

figure02_sales <- ggplot(data = LMs_API, aes(x = Year, y = sales_g_per_capita, colour = fct_inorder(API_Name), group = fct_inorder(API_Name))) +
    geom_point() +
    geom_smooth(method = "lm") +
    geom_pointrange(data = LM_Predictions, mapping = aes(x = Year, y = Pred, ymin = CI_95_lower, ymax = CI_95_upper)) +
    stat_poly_eq(method = "lm", use_label(c("eq", "R2")),
                 label.x = 0.75,
                 label.y = c(0.8, 0.9, 0.8, 0.9, 0.8, 0.9)) +
    scale_color_manual(breaks = c("ethinylestradiol", "estradiol","diclofenac", "ciprofloxacin", "paracetamol", "ibuprofen"),
                       values = c("magenta", "darkorchid", "mediumpurple1", "slateblue4", "dodgerblue1", "steelblue4"),
                       name = "API Name") +
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

figure02_sales
