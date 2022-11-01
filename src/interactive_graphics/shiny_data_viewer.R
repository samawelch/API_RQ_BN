### DATA PREPARATION
# Set up data from main RMD
pd_county <- splmaps::nor_nuts3_map_b2020_default_sf %>% 
    mutate(County_Code = str_extract(location_code, pattern = "[0-9]{2}")) %>% 
    left_join(county_codes, by = "County_Code") %>% 
    select(-location_code)

avg_RQ_county <- Hugin_Data_Output_Tall %>% 
    group_by(master_pop_scenario, master_year, master_WWT_scenario, master_county, API_Name) %>% 
    mutate(Risk_Bin_avg = case_when(Risk_Bin == "0-1" ~ 0.5,
                                    Risk_Bin == "1 - 10" ~ 5.5,
                                    Risk_Bin == "10-100" ~ 55,
                                    Risk_Bin == "100-1000" ~ 550,
                                    Risk_Bin == "1000-10000" ~ 5500,
                                    Risk_Bin == "10000-inf" ~ 10000),
           County_Name = master_county) %>% 
    summarise(Avg_RQ = sum(Risk_Bin_avg * Probability, na.rm = TRUE),
              County_Name,
              API_Name) %>% 
    ungroup() %>% 
    select(-master_county) %>% 
    distinct()

pd_county_joined <- merge(pd_county, avg_RQ_county)


Norway_map_bounds <- 
    Norway_counties_dataframe %>% 
    summarise(min_lat = min(lat),
              max_lat = max(lat),
              min_long = min(long),
              max_long = max(long))


### UI ###

ui <- bootstrapPage(
    tags$style(type = "text/css", "html, body {width:100%;height:100%}"),
    leafletOutput("map", width = "100%", height = "100%"),
    absolutePanel(top = 10, right = 10,
                  radioButtons(inputId = "radio_pop_scen", 
                               "Population Growth Scenario",
                               choices = list("Low", "Main", "High"),
                               selected = "Main"
                  ),
                  radioButtons(inputId = "radio_wwt_scen", 
                               "WWT Scenario",
                               choices = list("Current", "Compliance"),
                               selected = "Current"
                  ),
                  sliderInput("slider_year", "Year", min(pd_county_joined$master_year), max(pd_county_joined$master_year),
                              value = 2020, step = 30, sep = ""
                  ),
                  selectInput(inputId = "select_API_name",
                              "API or Group",
                              choices = c("Estradiol", "Ethinylestradiol", "Diclofenac",
                                          "Ibuprofen", "Paracetamol", "Ciprofloxacin",
                                          "Estrogens", "Antibiotics", "Painkillers", "Total"),
                              selected = "Total"
                  ),
                  checkboxInput("legend", "Show legend", TRUE
                  ),
                  textOutput("last_modified", container = tags$h6)
    )
)

### SERVER ###

server <- function(input, output, session) {
    
    # Reactive expression for the data subsetted to what the user selected
    pd_county_joined_filtered <- reactive({
        pd_county_joined %>% filter(master_year == input$slider_year,
                                    master_pop_scenario == input$radio_pop_scen,
                                    master_WWT_scenario == input$radio_wwt_scen,
                                    API_Name == input$select_API_name)
    })
    # Last modified date, taken from main .Rmd
    Hugin_Output_Last_Updated
    
    AvgRQ_Pal <- colorNumeric(palette = "viridis", domain = c(0, 6000))
    
    # Generate HTML labels from County info
    SumRQ_labels <- sprintf(
        "<strong>%s</strong><br/>Mean RQ = %g",
        pd_county_joined$County_Name, pd_county_joined$Avg_RQ
    ) %>% lapply(htmltools::HTML)
    
    output$map <- renderLeaflet({
        # Use leaflet() here, and only include aspects of the map that
        # won't need to change dynamically (at least, not unless the
        # entire map is being torn down and recreated).
        leaflet(pd_county_joined_filtered) %>% addTiles() %>%
            fitBounds(lng1 = 4.641979, lng2 = 31.05787, lat1 = 57.97976, lat2 = 71.18488)
    })
    
    # Incremental changes to the map (in this case, replacing the
    # circles when a new color is chosen) should be performed in
    # an observer. Each independent set of things that can change
    # should be managed in its own observer.
    
    observe({
        leafletProxy("map", data = pd_county_joined_filtered()) %>%
            clearShapes() %>%
            addPolygons(data = pd_county_joined_filtered(),
                        weight = 0.3,
                        opacity = 1,
                        fillColor = ~AvgRQ_Pal(Avg_RQ),
                        layerId = ~County_Name,
                        color = "white",
                        fillOpacity = 0.5,
                            highlightOptions = highlightOptions(
                            weight = 1,
                            color = "#666",
                            # If dashArray = "". as in the vignette, only the first polygon will appear
                            dashArray = NULL,
                            fillOpacity = 0.7,
                            bringToFront = TRUE),
                        label = ~sprintf(
                            "<strong>%s</strong><br/>Mean RQ = %g",
                            County_Name, Avg_RQ
                        ) %>% lapply(htmltools::HTML),
                        labelOptions = labelOptions(
                            style = list("font-weight" = "normal", padding = "3px 8px"),
                            textsize = "15px",
                            direction = "auto")
                        )
    })
    
    # Use a separate observer to recreate the legend as needed.
    observe({
        proxy <- leafletProxy("map", data = pd_county_joined_filtered)
        
        # Remove any existing legend, and only if the legend is
        # enabled, create a new one.
        proxy %>% clearControls()
        if (input$legend) {
            proxy %>% addLegend(position = "bottomright",
                                pal = AvgRQ_Pal, values = c(0, 6000)
            )
        }
    })
    # Print the date the dataset csv was last modified
    output$last_modified <- renderText({
        sprintf("Hugin Dataset last modified: %s", Hugin_Output_Last_Updated)
    })
}

shinyApp(ui, server)

# TODO:
# * Add RQ histograms on click
# * Host on shinyapps.io