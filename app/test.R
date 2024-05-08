# Import necessary packages and functions
import::from(dplyr, "mutate", "filter", "select")
import::from(leaflet, "leaflet", "leafletOptions", "setView", "addTiles", "addMarkers", "clearTiles", "addProviderTiles", "leafletProxy", "clearGroup", "fitBounds", "markerClusterOptions", "addAwesomeMarkers", "addLegend", "leafletOutput", "awesomeIcons")
import::from(leaflet.extras, "addHeatmap")
import::from(shiny, "fluidPage",  "div", "tags", "selectInput", "checkboxInput", "actionButton", "observe", "reactive", "observeEvent")
import::from(shinyjs, "useShinyjs", "addClass", "removeClass")
import::from(shinyWidgets, "sliderTextInput", "updateSliderTextInput")
import::from(htmlwidgets, "onRender")



# Define UI
ui <- fluidPage(
  useShinyjs(),
  tags$head(tags$head(includeCSS("www/custom.css"))),
  div(
    style = "position: absolute; top: 110px; right: 30px; z-index:  1001;",
    actionButton("toggle_map", "", icon = icon("map"), style = "border: none; border-radius: 10px; padding:8px;")
  ),
  leafletOutput("map", width = "100%", height = "calc(100% - 80px)"),
  div(class = "leaflet-dropdown-menu",
      selectInput(
        "dropdown",
        label = NULL,
        choices = c("Nids de Goelands", "Sur les traces de BigFoot", "Option 3")
      )
  ),
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
  div(
    class = "leaflet-left-panel",
    h3("Left Side Panel"),
    p("This is a left side panel floating at 50px from the left side."),
    checkboxInput("darkmode", "Dark Mode", value = FALSE),
    checkboxInput("density_toggle", "Show Data Density", value = FALSE),
    uiOutput("buttonSet")
  )
)

# Define server logic
server <- function(input, output, session) {


  output$buttonSet <- renderUI({
    if (!is.null(color_palette)) {
      labels <- color_palette()
      colors <- color_palette()
      image_urls <- color_palette()

      button_set_html <- generate_button_set(labels, colors, image_urls)

      HTML(button_set_html)
    } else {
      # If color_palette is not defined or null, return a message or handle accordingly
      HTML("<p>Color palette is not defined or is null.</p>")
    }
  })

  # Reactive expression for selected data based on dropdown selection
  selected_data <- reactive({
    switch(
      input$dropdown,
      "Nids de Goelands" = data1,
      "Sur les traces de BigFoot" = data2,
      "Option 3" = data3
    )
  })

  selected_icon <- reactive({
    switch(
      input$dropdown,
      "Nids de Goelands" = "crow",
      "Sur les traces de BigFoot" = "shoe-prints",
      "Option 3" = "shoe-prints"
    )
  })

  color_palette <- reactive({
    switch(
      input$dropdown,
      "Nids de Goelands" =  c("Argenté" = "#B0C4DE",   # Silver
                              "Marin" = "#4682B4",     # Steel Blue
                              "Brun" = "#8B4513",     # Saddle Brown
                              "ND" = "#D3D3D3"),        # Light Gray,
      "Sur les traces de BigFoot" = c("Class A" = "#FF0000",   # Red
                                      "Class B" = "#FFFF00",   # Yellow
                                      "Class C" = "#008000"),  # Green,
      "Option 3" = c("Class A" = "#FF0000",   # Red
                     "Class B" = "#FFFF00",   # Yellow
                     "Class C" = "#008000")  # Green
    )
  })

  # Reactive expression for filtered data based on slider input
  filtered_data <- reactive({
    subset(selected_data(),
           annee >= input$annee_slider[1] &
             annee <= input$annee_slider[2]) %>%
      select(-annee) %>% unique()
  })

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
    leafletProxy("map") %>%
      clearTiles() %>%
      addProviderTiles(ifelse(input$toggle_map %% 2 != 0, "Esri.WorldImagery", "OpenStreetMap"))
  })

  # Observe changes in the year slider and update markers on the map
  observeEvent(input$annee_slider, {
    if (length(filtered_data() > 0 && !is.null(color_palette()))) {
      leafletProxy("map") %>%
        clearGroup("marker_map") %>%
        addAwesomeMarkers(data = filtered_data(),
                          label = ~as.character(label_col),
                          popup = ~as.character(popup_col),
                          clusterOptions = markerClusterOptions(),
                          icon = ~awesomeIcons(icon = selected_icon(), library = "fa", markerColor = customMarkerColor(color_palette())),
                          group = "marker_map")
    } else {
      leafletProxy("map") %>%
        clearGroup("marker_map")
    }
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

  # Observe the dark mode checkbox and update the app CSS accordingly
  observeEvent(input$darkmode, {
    if (input$darkmode) {
      addClass(selector = "body", class = "dark-mode")
    } else {
      removeClass(selector = "body", class = "dark-mode")
    }
  })
}



