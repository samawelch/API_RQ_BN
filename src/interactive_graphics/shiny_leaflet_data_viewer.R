# Leaflet/Shiny Map with Optional Minicharts

### DATA ###########################################################################################

# Leaflet.minicharts data w/ centroids, data table format
RQ_county <- avg_RQ_county %>% 
    select(-Avg_RQ) %>% 
    left_join(Norway_county_map_centroids, by = "County_Name") %>% 
    group_by(County_Name) %>% 
    # Needs a numerical ID by county name
    mutate(County_ID = cur_group_id())

### BASEMAP ########################################################################################

# Create base map
base_map_Norway <- 
    leaflet(data = RQ_county,
            width = "100%", height = "400px") %>%
    addProviderTiles(providers$Stamen.Watercolor)

leaflet() %>% addProviderTiles() %>%
    fitBounds(lng1 = 4.641979, lng2 = 31.05787, lat1 = 57.97976, lat2 = 71.18488) 


### UI #############################################################################################

ui <- fluidPage(
    titlePanel("Demo of leaflet.minicharts"),
    
    sidebarLayout(
        
        sidebarPanel(
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
            radioButtons(inputId = "radio_display_pies", 
                         "Show Risk Pie Charts?",
                         choices = list("Yes", "No"),
                         selected = "No"
            ),
            textOutput("last_modified", container = tags$h6)
        ),
        
        mainPanel(
            leafletOutput("map")
        )
        
    )
)

### SERVER #########################################################################################

function(input, output, session) {
    # Initialize map
    output$map <- renderLeaflet({
        base_map_Norway %>%
            addMinicharts(
                RQ_county$long, RQ_county$lat,
                layerId = RQ_county$County_ID,
                width = 45, height = 45,
                type = "pie"
            )
    })
    # 
    # # Update charts each time input value changes
    # observe({
    #     RQ_county_filtered <- RQ_county %>% 
    #         filter(master_year == input$slider_year)
    #     
    #     leafletProxy("map", session) %>%
    #         updateMinicharts(
    #             RQ_county_filtered$County_ID,
    #             chartdata = RQ_county_filtered
    #         )
    # })
}

### APP ############################################################################################
shinyApp(ui, server)