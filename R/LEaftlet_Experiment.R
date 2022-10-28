# Little Baby Leaflet Test Project
# I'm taking just under 2 hours to try and make an interactive implementation of my maps
# Needs you to run the main RMD first...

library(splmaps)
library(tidyverse)
library(sf)
library(leaflet)
library(rgdal)
library(shiny)

pd_county <- splmaps::nor_nuts3_map_b2020_default_sf %>% 
    mutate(County_Code = str_extract(location_code, pattern = "[0-9]{2}")) %>% 
    left_join(county_codes, by = "County_Code") %>% 
        select(-location_code)

avg_sumRQ_county <- Hugin_Data_Output_Tall %>% 
    filter(Risk_Type == "SumRQ", API_Name == "Total") %>% 
    group_by(master_pop_scenario, master_year, master_WWT_scenario, master_county) %>% 
    mutate(Risk_Bin_avg = case_when(Risk_Bin == "0-1" ~ 0.5,
                                       Risk_Bin == "1 - 10" ~ 5.5,
                                       Risk_Bin == "10-100" ~ 55,
                                       Risk_Bin == "100-1000" ~ 550,
                                       Risk_Bin == "1000-10000" ~ 5500,
                                       Risk_Bin == "10000-inf" ~ 10000),
           County_Name = master_county) %>% 
    summarise(Avg_SumRQ = sum(Risk_Bin_avg * Probability, na.rm = TRUE),
              County_Name) %>% 
    ungroup() %>% 
    select(-master_county) %>% 
    # Filter to one scenario combination for now
    filter(master_pop_scenario == "Main", master_year == 2020, master_WWT_scenario == "Compliance") %>% 
    distinct()


pd_county_joined <- merge(pd_county, avg_sumRQ_county)

    

# Create a palette for average Sum RQs
SumRQ_Pal <- colorNumeric(palette = "viridis", domain = pd_county_joined$Avg_SumRQ)

# Generate HTML labels from County info
SumRQ_labels <- sprintf(
    "<strong>%s</strong><br/>Mean sum of RQs = %g",
    pd_county_joined$County_Name, pd_county_joined$Avg_SumRQ
) %>% lapply(htmltools::HTML)

    
test_leaflet <- leaflet(
    pd_county_joined,
    options = leaflet::leafletOptions(preferCanvas = F)) %>%
    # Add ESRI's grey world underlay
    leaflet::addProviderTiles(leaflet::providers$Esri.WorldGrayCanvas) %>%
    leaflet::addPolygons(
        weight = 0.3,
        opacity = 1,
        # Use the previously made palette to colour counties
        fillColor = ~SumRQ_Pal(Avg_SumRQ), 
        color = "white",
        fillOpacity = 0.9,
        highlightOptions = highlightOptions(
            weight = 1,
            color = "#666",
            # If dashArray = "". as in the vignette, only the first polygon will appear
            dashArray = NULL,
            fillOpacity = 0.7,
            bringToFront = TRUE),
        label = SumRQ_labels,
        labelOptions = labelOptions(
            style = list("font-weight" = "normal", padding = "3px 8px"),
            textsize = "15px",
            direction = "auto"))

test_leaflet

# Now we have the base map working, the next step to to add a sliders/dropdowns for scenario
# and render a plot of probability distribution when you click a county
# this is complicated, and requires Shiny

# Basics of Shiny

runExample("01_hello")

