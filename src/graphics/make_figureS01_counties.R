# Append county names to the CSDS map file, and find centroids for future use

Norway_counties_sf <- nor_county_map_b2020_default_sf |> 
    mutate(County_Code = str_extract(location_code, "[0-9]{2}"))

# Append county names to the SPL map
Norway_county_map_names <- Norway_counties_sf %>% 
    left_join(county_codes, by = "County_Code") %>% 
    left_join(pop_by_county_2020, by = "County_Name")

# Find the centroids of counties for better labelling
# Norway_county_map_centroids <- Norway_county_map_names %>% 
#     group_by(County_Name) %>% 
#     st_centroid()

Norway_county_map <- ggplot(data = Norway_county_map_names) + 
    geom_sf(color = "grey",
            linewidth = 0.3) +
    theme_void() 

Norway_county_map_data <- Norway_county_map_names %>% 
    select(-Population) %>% 
    left_join(Norway_County_General_2020, by = c("County_Name"))


Norway_County_General_2020 <- Norway_County_General_2020 %>% 
    mutate(Pop_mil = Population / 1e6,
           urb_quantile = str_replace_all(urb_quantile, c(Urban = "U", 
                                                          `Semi-` = "S",
                                                          Rural = "R")))


# 
# Norway_ylim <- c(4.641979 - 0.5, max(Norway_counties_dataframe$lat) + 0.5)
# Norway_xlim <- c(min(Norway_counties_dataframe$long) - 0.5, max(Norway_counties_dataframe$long) + 0.5)

# Switch to planar geometry (needed to crop world to bounding box)
sf_use_s2(FALSE)

world <- ne_countries(scale = "medium", returnclass = "sf") |> 
    st_make_valid() |> 
    st_crop(xmin = -1, ymin = 57, xmax = 32, ymax = 73) 

Norway_county_map <- ggplot(data = world) + 
    geom_sf() +
    geom_sf(data = Norway_county_map_data, aes(fill = Type)) +
    coord_sf(expand = FALSE) +
    theme_bw() +
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
figureS01_counties <- plot_grid(Norway_county_map,
                                   Norway_county_boxplots,
                                   nrow = 1,
                                   rel_widths = c(1.5, 1.5),
                                   align = "h")

figureS01_counties
