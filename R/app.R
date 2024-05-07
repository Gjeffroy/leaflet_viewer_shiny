# Import necessary packages and functions
import::from(dplyr, "mutate", "filter", "select")
import::from(leaflet, "leafletOptions", "setView", "addTiles", "addMarkers", "clearTiles", "addProviderTiles", "leafletProxy", "clearGroup", "fitBounds", "markerClusterOptions")
import::from(leaflet.extras, "addHeatmap")
import::from(shiny, "fluidPage",  "div", "tags", "selectInput", "checkboxInput", "actionButton", "observe", "reactive", "observeEvent")
import::from(shinyjs, "useShinyjs", "addClass", "removeClass")
import::from(shinyWidgets, "sliderTextInput", "updateSliderTextInput")
import::from(htmlwidgets, "onRender")




# Define the user interface (UI)
ui <- fluidPage(
  # Use shinyjs package
  useShinyjs(),
  # Include custom CSS file
  tags$head(tags$head(includeCSS("www/custom.css"))),
  # Create a button for toggling the map
  div(
    style = "position: absolute; top: 110px; right: 30px; z-index:  1001;",
    actionButton("toggle_map", "",
                 icon = icon("map"),
                 style = "border: none; border-radius: 10px; padding:8px;")
  ),
  # Output area for the leaflet map
  leafletOutput("map", width = "100%", height = "calc(100% - 80px)"),
  # Dropdown menu for selecting data
  div(class = "leaflet-dropdown-menu",
      selectInput(
        "dropdown",
        label = NULL,
        choices = c("Nids de Goelands", "Sur les traces de BigFoot", "Option 3")
      )),
  # Slider for selecting years
  div(
    class = "slider-container",
    sliderTextInput(
      "annee_slider",
      label = NULL,
      grid = TRUE,
      force_edges = TRUE,
      animate = TRUE,
      choices = seq(0, 100, by = 1),
      selected = c(25, 75),
      width = "100%"
    )
  ),
  # Left side panel
  div(
    class = "leaflet-left-panel",
    h3("Left Side Panel"),
    p("This is a left side panel floating at 50px from the left side."),
    checkboxInput("darkmode", "Dark Mode", value = FALSE),
    checkboxInput("density_toggle", "Show Data Density", value = FALSE)
  )
)

# Define the server logic
server <- function(input, output, session) {

  # ---- SELECT AND FILTER DATA ----
  # Reactive expression for selected data based on dropdown selection
  selected_data <- reactive({
    switch(
      input$dropdown,
      "Nids de Goelands" = data1,
      "Sur les traces de BigFoot" = data2,
      "Option 3" = data3
    )
  })

  # Reactive expression for filtered data based on slider input
  filtered_data <- reactive({
    subset(selected_data(),
           annee >= input$annee_slider[1] &
             annee <= input$annee_slider[2]) %>%
      select(-annee) %>% unique()

  })

  observe(print(summary(filtered_data())))


  # ---- UPDATE INPUT ---
  # Update the slider based on selected data
  observe({
    data <- selected_data()
    min_year <- round(min(data$annee))
    max_year <- round(max(data$annee))
    updateSliderTextInput(
      session,
      "annee_slider",
      choices = seq(min_year, max_year, by = 1),
      selected = c(min_year, max_year)
    )
  })

  # ---- LEAFLET MAP ----
  # Render the initial leaflet map
  output$map <- renderLeaflet({
    leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
      onRender("function(el, x) {
        L.control.zoom({ position: 'topright' }).addTo(this)
    }") %>%
      addTiles()
  })


  # Observe the toggle map button and switch between map layers
  observeEvent(input$toggle_map, {
    if (input$toggle_map %% 2 != 0) {
      leafletProxy("map") %>%
        clearTiles() %>%
        addProviderTiles("Esri.WorldImagery")
    } else {
      leafletProxy("map") %>%
        clearTiles() %>%
        addTiles()
    }
  })

  # Observe changes in the year slider and update markers on the map
  observeEvent(input$annee_slider, {
    leafletProxy("map") %>%
      clearGroup("marker_map") %>%
      addMarkers(data = filtered_data(),
                 clusterOptions = markerClusterOptions(),
                 group = "marker_map")
  })

  # Observe changes in data density toggle and update heatmap layer
  observeEvent(list(input$density_toggle, input$annee_slider), {
    data <- filtered_data()

    leafletProxy("map") %>%
      clearGroup("density_heatmap")

    if (input$density_toggle) {
      leafletProxy("map") %>%
        addHeatmap(
          data = data,
          blur = 30,
          radius = 20,
          group = "density_heatmap"
        )
    } else {
      leafletProxy("map") %>%
        clearGroup("density_heatmap")
    }
  })

  # Observe changes in dropdown selection and fit map bounds accordingly
  observeEvent(input$dropdown, {
    data <- selected_data()
    leafletProxy("map") %>%
      fitBounds(
        lng1 = min(data$lng),
        lat1 = min(data$lat),
        lng2 = max(data$lng),
        lat2 = max(data$lat)
      )
  })

  # ---- DARK MODE ---
  # Observe the dark mode checkbox and update the app CSS accordingly
  observeEvent(input$darkmode, {
    if (input$darkmode) {
      addClass(selector = "body", class = "dark-mode")
    } else {
      removeClass(selector = "body", class = "dark-mode")
    }
  })
}
