# Cities of 50,000+ only
Norway_Cities %>% filter(population > 50000) %>% 
    summarise(sum(population))
# This covers only 2.1 million people, not even half of the population
# Removing the filter covers 4.3 million people, which is better...

Norway_county_cities_map <- ggplot(data = Norway_county_map_names, mapping = aes(x = long, 
                                                                                 y = lat)) + 
    geom_polygon(color = "grey",
                 size = 0.1,
                 aes(group = group,
                     fill = Population)) +
    scale_fill_distiller(type = "seq",
                         direction = 1,
                         palette = "Greys") +
    geom_text_repel(data = Norway_county_map_centroids,
                    size = 4,
                    alpha = 0.5,
                    mapping = aes(label = County_Name),) +
    geom_point(data = Norway_Cities %>% filter(population > 50000),
               alpha = 1,
               colour = "red",
               aes(size = population)) +
    geom_label_repel(data = Norway_Cities %>% filter(population > 50000), 
                     mapping = aes(label = city))

Norway_county_cities_map