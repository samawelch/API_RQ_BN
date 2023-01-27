# Make a map of Norway with pie charts per fylke depicting access to various WWTP levels
# I'd love to do this automatically, but scatterpie is too primitive and I'm strapped for time

Norway_county_map_data <- Norway_county_map_names %>% 
    select(-Population) %>% 
    left_join(Norway_County_General_2020, by = c("County_Name"))


Norway_County_General_2020 <- Norway_County_General_2020 %>% 
    mutate(Pop_mil = Population / 1e6)

library("rnaturalearth")
library("rnaturalearthdata")
library(ggrepel)

Norway_ylim <- c(min(Norway_counties_dataframe$lat) - 0.5, max(Norway_counties_dataframe$lat) + 0.5)
Norway_xlim <- c(min(Norway_counties_dataframe$long) - 0.5, max(Norway_counties_dataframe$long) + 0.5)

world <- ne_countries(scale = "medium", returnclass = "sf")
class(world)

Norway_county_map <- ggplot(data = world) + 
    geom_sf() +
    geom_sf(data = Norway_county_map_data, aes(fill = Type)) +
    theme_bw() +
    coord_sf(xlim = Norway_xlim, ylim = Norway_ylim, expand = FALSE) +
    scale_fill_brewer(palette = "Paired") +
    geom_label_repel(Norway_county_map_data, 
                     mapping = aes(label = County_Name,
                                   geometry = geometry),
                                   stat = "sf_coordinates",
                                   min.segment.length = 0) +
    theme(legend.position = c(0.16,0.86)) +
    labs(title = "(a) Map of Norway 2020 Counties by Urbanisation Quantile", x = "Longitude", y = "Latitude") +
    theme(panel.grid.major = element_line(color = gray(0.5), 
                                          linetype = "dashed", 
                                          linewidth = 0.5),
          legend.box.background = element_rect(color = "black", 
                                               linewidth = 0.5),
          panel.background = element_rect(fill = "aliceblue"))

Norway_county_map

# Boxplots of County Variation
Norway_county_boxplot_urb <- 
    ggplot(data = Norway_County_General_2020, mapping = aes(x = urb_quantile, y = pop_urban)) +
    geom_point(aes(colour = Type, shape = exemplar), size = 3, stroke = 2) +
    scale_shape_manual(values = c(1, 16)) +
    scale_colour_brewer(palette = "Paired") +
    geom_boxplot(alpha = 0) +
    theme_bw() +
    theme(legend.position = "none") +
    labs(title = "(b) Proportion of Pop. in Urban Areas",
         x = "Urbanisation Quartile", 
         y = "Urban Population Proportion")

# Norway_county_boxplot_urb

Norway_county_boxplot_pop <- 
    ggplot(data = Norway_County_General_2020, mapping = aes(x = urb_quantile, y = Pop_mil)) +
    geom_point(aes(colour = Type, shape = exemplar), size = 3, stroke = 2) +
    scale_shape_manual(values = c(1, 16)) +
    scale_colour_brewer(palette = "Paired") +
    geom_boxplot(alpha = 0) +
    theme_bw() +
    theme(legend.position = "none") +
    labs(title = "(c) Total Population",
         x = "Urbanisation Quartile", 
         y = "County Population (mil)")

# Norway_county_boxplot_pop

Norway_county_boxplot_ww <- 
    ggplot(data = Norway_County_General_2020, mapping = aes(x = urb_quantile, y = Consumption_PPerson_PDay)) +
    geom_point(aes(colour = Type, shape = exemplar), size = 3, stroke = 2) +
    scale_colour_brewer(palette = "Paired") +
    scale_shape_manual(values = c(1, 16)) +
    geom_boxplot(alpha = 0) +
    theme_bw() +
    theme(legend.position = "none") +
    labs(title = "(d) Wastewater (L.person-1.day-1)",
         x = "Urbanisation Quartile", 
         y = "Wastewater Produced Per Person Per Day (L)")

# Norway_county_boxplot_ww

Norway_county_boxplot_wwt <- 
    ggplot(data = Norway_County_General_2020, mapping = aes(x = urb_quantile, y = Arbitrary_WWT_Index)) +
    geom_point(aes(colour = Type, shape = exemplar), size = 3, stroke = 2) +
    scale_shape_manual(values = c(1, 16)) +
    scale_colour_brewer(palette = "Paired") +
    geom_boxplot(alpha = 0) +
    theme_bw() +
    theme(legend.position = "none") +
    labs(title = "(e) Wastewater Treatment Index",
         x = "Urbanisation Quartile", 
         y = "Arbitrary Wastewater Treatment Index")

# Norway_county_boxplot_wwt

Norway_county_boxplots <- plot_grid(Norway_county_boxplot_urb,
                                    Norway_county_boxplot_pop,
                                    Norway_county_boxplot_ww,
                                    Norway_county_boxplot_wwt, 
                                    nrow = 2)
Norway_county_graphic <- plot_grid(Norway_county_map,
                                   Norway_county_boxplots,
                                   nrow = 1,
                                   rel_widths = c(1.5, 1.5))

Norway_county_graphic
# Pie charts

# # Generate some additional scenario pies for the whole country
# wwt_share_total_by_scenario <- wwt_share_by_county_2020 %>% filter(County_Name == "Total") %>% 
#     crossing(Scenario = c("2+", "3")) %>% 
#     arrange(Scenario) %>% 
#     mutate(County_Name = paste0(County_Name, Scenario))
# # By hand is faster than figuring out how to write the code
# wwt_share_total_by_scenario$wwt_pop_share <- c(0, 0, 1 - 0.36459325, 0.36459325,
#                                                0, 0, 0, 1)
# 
# wwt_share_by_county_scenario <- wwt_share_by_county_2020 %>% rbind(wwt_share_total_by_scenario)
# wwt_share_by_county_scenario
# 
# Norway_county_pies_WWT <- ggplot(data = wwt_share_by_county_scenario , 
#                                  mapping = aes(fill = Class_EU, 
#                                                x = 0, 
#                                                y = wwt_pop_share,
#                                                group = County_Name)) +
#     geom_bar(width = 1, stat = "identity") +
#     coord_polar(theta = "y") +
#     facet_wrap(~County_Name) +
#     scale_fill_viridis_d(option = "viridis", begin = 0, end = 0.5) +
#     theme_void()
# 
# Norway_county_pies_WWT
# 
# API_removal_rates_bars <- API_removal_rates %>% 
#     mutate(API_Name = fct_relevel(API_Name, c("estradiol", "ethinylestradiol", "ciprofloxacin", "diclofenac",
#                                               "ibuprofen", "paracetamol", "mean"))) %>% 
#     ggplot(mapping = aes(x = API_Name, 
#                          y = removal_rate_perc, 
#                          fill = fct_inorder(treatment))) +
#     geom_col(position = "dodge") +
#     scale_fill_viridis_d(name = "Removal Type", 
#                          labels = c("Primary", "Secondary", "Tertiary", "Advanced", "Ozone", "Activated Carbon")) +
#     theme_minimal() +
#     labs(x = "API", y = "Removal Rate (%)", )
# 
# API_removal_rates_bars
# 
# wwt_share_by_county_2020 %>% group_by(County_Name) %>% summarise(sum((wwt_pop_share)))
# 
# # Water consumption per county
# ggplot(data = Norway_Wastewater_County_2020, mapping = aes(x = County_Name, y = Consumption_PPerson_PDay)) +
#     geom_col()