# Make a map of Norway with pie charts per fylke depicting access to various WWTP levels
# I'd love to do this automatically, but scatterpie is too primitive and I'm strapped for time

Norway_county_map_data <- Norway_county_map_names %>% 
    select(-Population) %>% 
    left_join(Norway_County_General_2020, by = c("County_Name"))


Norway_County_General_2020 <- Norway_County_General_2020 %>% 
    mutate(Pop_mil = Population / 1e6,
           urb_quantile = str_replace_all(urb_quantile, c(Urban = "U", 
                                                          `Semi-` = "S",
                                                          Rural = "R")))

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
    theme(legend.position = c(0.775, 0.19)) +
    labs(title = "(a)", x = "Longitude", y = "Latitude") +
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
    theme(legend.position = "none", axis.title.y = element_blank()) +
    labs(title = "(b)",
         y = "Urban Population Proportion") +
    coord_flip()

# Norway_county_boxplot_urb

Norway_county_boxplot_pop <- 
    ggplot(data = Norway_County_General_2020, mapping = aes(x = urb_quantile, y = Pop_mil)) +
    geom_point(aes(colour = Type, shape = exemplar), size = 3, stroke = 2) +
    scale_shape_manual(values = c(1, 16)) +
    scale_colour_brewer(palette = "Paired") +
    geom_boxplot(alpha = 0) +
    theme_bw() +
    theme(legend.position = "none", axis.title.y = element_blank()) +
    labs(title = "(c)",
         y = "County Population (mil)") +
    coord_flip()

# Norway_county_boxplot_pop

Norway_county_boxplot_ww <- 
    ggplot(data = Norway_County_General_2020, mapping = aes(x = urb_quantile, y = Consumption_PPerson_PDay)) +
    geom_point(aes(colour = Type, shape = exemplar), size = 3, stroke = 2) +
    scale_colour_brewer(palette = "Paired") +
    scale_shape_manual(values = c(1, 16)) +
    geom_boxplot(alpha = 0) +
    theme_bw() +
    theme(legend.position = "none", axis.title.y = element_blank()) +
    labs(title = "(d)",
         y = str_wrap("Wastewater Produced Per Person Per Day (L)", width = 100)) +
    coord_flip()

# Norway_county_boxplot_ww

Norway_county_boxplot_wwt <- 
    ggplot(data = Norway_County_General_2020, mapping = aes(x = urb_quantile, y = Arbitrary_WWT_Index)) +
    geom_point(aes(colour = Type, shape = exemplar), size = 3, stroke = 2) +
    scale_shape_manual(values = c(1, 16)) +
    scale_colour_brewer(palette = "Paired") +
    geom_boxplot(alpha = 0) +
    theme_bw() +
    theme(legend.position = "none", axis.title.y = element_blank()) +
    labs(title = "(e)",
         y = str_wrap("Arbitrary Wastewater Treatment Index"), width = 100) +
    coord_flip()

# Norway_county_boxplot_wwt

Norway_county_boxplots <- plot_grid(Norway_county_boxplot_urb,
                                    Norway_county_boxplot_pop,
                                    Norway_county_boxplot_ww,
                                    Norway_county_boxplot_wwt, 
                                    nrow = 4)
Norway_county_graphic <- plot_grid(Norway_county_map,
                                   Norway_county_boxplots,
                                   nrow = 1,
                                   rel_widths = c(1.5, 1.5),
                                   align = "h")

Norway_county_graphic
