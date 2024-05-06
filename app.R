library(shiny)
library(leaflet)
library(shinyjs)
library(shinyWidgets)
library(MASS)
library(leaflet.extras)
source('data.R')

# Sample datasets (replace with your actual datasets)
data1 <-  open_csv_select_columns(
  './sterilisations-de-nids-de-goelands-ville-de-lorient.csv',
  selected_columns = c(
    "nid_support",
    "nid_traite"
  ),
  sep = ";"
)

data2 <- open_csv_select_columns(
  './sterilisations-de-nids-de-goelands-ville-de-lorient.csv',
  selected_columns = c(
    "nid_support"
  ),
  sep = ";"
)

data3 <- data.frame(
  lat = c(33.7490, 37.7749, 34.0522),
  lng = c(-84.3880, -122.4194, -118.2437),
  name = c("Atlanta", "San Francisco", "Los Angeles")
)

ui <- fluidPage(
  useShinyjs(),  # Enable shinyjs

  tags$head(
    tags$style(HTML("
      body, html, .container-fluid {
        height: 100%;
        margin: 0;
        padding: 0;
      }
      .leaflet-left-panel {
        position: absolute;
        top: 20px; /* Adjusted to prevent overlap with slider */
        left: 20px;
        width: 300px;
        height: calc(100% - 145px); /* Adjusted for bottom padding and slider */
        background-color: #ffffff; /* Light mode background color */
        border-right: 1px solid #ccc;
        z-index: 1000;
        overflow-y: auto;
        padding: 10px;
        border-radius: 5px; /* Rounded corners */
      }
      .leaflet-dropdown-menu {
        position: absolute;
        top: 10px;
        left: 50%;
        height: auto;
        transform: translateX(-50%);
        background-color: #ffffff; /* Light mode background color */
        border: 1px solid #ccc;
        border-radius: 5px;
        padding: 5px;
        z-index: 1001; /* Ensure it's above the map */
      }
      .leaflet-dropdown-menu .form-group {
          margin-bottom: 0px;
      }

      .slider-container {
        position: absolute;
        bottom: 0;
        width: 100%;
        padding: 0;
        background-color: #ffffff; /* Light mode background color */
        border-top: None;
        box-shadow: 0 -2px 5px rgba(0, 0, 0, 0.1);
      }
      .slider-container .form-group {
        margin-bottom: 0;
      }
      .leaflet-top.leaflet-right {
        top: 20px; /* Adjusted to prevent overlap with dropdown menu */
        right: 20px;
      }
      /* Dark mode styles */
      body.dark-mode {
        background-color: #202124; /* Dark mode background color */
        color: #cccccc; /* Dark mode text color */
      }
      body.dark-mode .leaflet-left-panel,
      body.dark-mode .leaflet-dropdown-menu,
      body.dark-mode .slider-container {
        background-color: #2c2c2c; /* Dark mode background color for panels */
        color: #cccccc; /* Dark mode text color for panels */
        border-color: #555555; /* Dark mode border color for panels */
      }
      /* Additional dark mode styles */
      body.dark-mode .leaflet-layer,
      body.dark-mode .leaflet-control-attribution {
        filter: invert(100%) hue-rotate(180deg) brightness(95%) contrast(90%);
      }

      /* Play button styling */
      .irs-play {
        font-size: 30px; /* Adjust size */
        left: 0px !important; /* Position to the left */
      }

      .slider-animate-container{
        padding: 0px 15px 0px 15px;
        margin:0;
      }

      .slider-container .form-group {
        display: flex;
        justify-content: space-evenly;
        align-items: center;
        border: 1px solid #ccc;
        padding: 10px;
      }

      .slider-animate-button {
        font-size: 20pt !important;
        text-align: left;
        margin-top: -9px;
        order: 1;
      }

      .irs--shiny {
        width: 100%;
        order: 2;
      }

      /* Dark mode for button, dropdown, and slider */
      .dark-mode .btn-default,
      .dark-mode .selectize-input,
      .dark-mode .irs-bar,
      body.dark-mode .leaflet-control-zoom-in,
      body.dark-mode .leaflet-control-zoom-out{
        background-color: #383838;
        color: #cccccc;
      }

      .dark-mode .irs-single, .dark-mode .irs-from, .dark-mode .irs-to, .dark-mode .irs-slider {
        background: #cccccc;
      }

    "))

  ),
  div(
    style = "position: absolute; top: 110px; right: 30px; z-index:  1001;",
    actionButton("toggle_map", "",
                 icon = icon("map"),
                 style = "border: none; border-radius: 10px; padding:8px;"
    )
  ),
  leafletOutput("map", width="100%",height="calc(100% - 80px)"),
  div(class = "leaflet-dropdown-menu",
      selectInput("dropdown", label = NULL, choices = c("Nids de Goelands", "Option 2", "Option 3"))
  ),
  div(class = "slider-container",
      sliderTextInput("annee_slider", label = NULL, grid = TRUE, force_edges = TRUE, animate = TRUE,
                      choices = seq(0, 100, by = 1), selected = c(25, 75),
                      width = "100%")
  ),
  div(class = "leaflet-left-panel",
      h3("Left Side Panel"),
      p("This is a left side panel floating at 50px from the left side."),
      checkboxInput("darkmode", "Dark Mode", value = FALSE),  # Add dark mode toggle
      checkboxInput("density_toggle", "Show Data Density", value = FALSE)
  )
)

server <- function(input, output, session) {

  # Reactive expression to load selected dataset based on dropdown
  selected_data <- reactive({
    switch(input$dropdown,
           "Nids de Goelands" = data1,
           "Option 2" = data2,
           "Option 3" = data3)
  })

  # Filtered data
  filtered_data <- reactive({
    subset(selected_data(), annee >= input$annee_slider[1] & annee <= input$annee_slider[2]) %>%
      select(-annee) %>% unique()
  })



  # Update the slider choices based on the selected dataset
  observe({
    data <- selected_data()
    min_year <- round(min(data$annee))
    max_year <- round(max(data$annee))
    updateSliderTextInput(session, "annee_slider",
                          choices = seq(min_year, max_year, by = 1),
                          selected = c(min_year, max_year))
  })

  # Render map
  output$map <- leaflet::renderLeaflet({
    leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
      htmlwidgets::onRender("function(el, x) {
        L.control.zoom({ position: 'topright' }).addTo(this)
    }") %>%
      setView(lng = -95.7129, lat = 37.0902, zoom = 4) %>%
      addTiles()
    # Customize your leaflet map here
  })

  # Toggle dark mode
  observeEvent(input$darkmode, {
    if (input$darkmode) {
      shinyjs::addClass(selector = "body", class = "dark-mode")
    } else {
      shinyjs::removeClass(selector = "body", class = "dark-mode")
    }
  })

  # Toggle map provider
  observeEvent(input$toggle_map, {
    if(input$toggle_map %% 2 != 0){
      leafletProxy("map") %>%
        clearTiles() %>%
        addProviderTiles("Esri.WorldImagery")
    } else {
      leafletProxy("map") %>%
        clearTiles() %>%
        addTiles()
    }
  })

  # Filter and update map markers based on slider input
  observeEvent(input$annee_slider, {
    leafletProxy("map") %>%
      clearGroup("marker_map") %>%
      addMarkers(data = filtered_data(), clusterOptions = markerClusterOptions(), group = "marker_map")
  })

  # Add or remove data density layer based on checkbox state
  observeEvent(list(input$density_toggle,input$annee_slider),{
    data <- filtered_data()

    leafletProxy("map") %>%
      clearGroup("density_heatmap")

    if(input$density_toggle) {
      leafletProxy("map") %>%
        addHeatmap(data = data, blur = 30, radius = 20, group = "density_heatmap")
    } else {
      leafletProxy("map") %>%
        clearGroup("density_heatmap")
    }
  })

  observeEvent(input$dropdown, {
    data <- selected_data()
    leafletProxy("map") %>%
      fitBounds(lng1 = min(data$lng),
                lat1 = min(data$lat),
                lng2 = max(data$lng),
                lat2 = max(data$lat))
  })

}

shinyApp(ui, server)
