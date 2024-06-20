# Import necessary packages and functions
import::from(dplyr, "mutate", "filter", "select")
import::from(leaflet, "leaflet", "leafletOptions", "setView", "addTiles", "addMarkers", "clearTiles", "addProviderTiles", "leafletProxy", "clearGroup", "fitBounds", "markerClusterOptions", "addAwesomeMarkers", "addLegend", "leafletOutput", "awesomeIcons", "renderLeaflet")
import::from(leaflet.extras, "addHeatmap")
import::from(shiny, "fluidPage",  "div", "tags", "selectInput", "checkboxInput", "actionButton", "observe", "reactive", "observeEvent")
import::from(shinyjs, "useShinyjs", "addClass", "removeClass")
import::from(shinyWidgets, "sliderTextInput", "updateSliderTextInput")
import::from(htmlwidgets, "onRender")


# Loading Goeland dataset
data1 <- open_goeland_csv(
  './data/sterilisations-de-nids-de-goelands-ville-de-lorient.csv',
  label_col = "nid_espece",
  popup_col = "nid_support",
  sep = ";"
) %>% filter(label_col != 'ND')



# Loading Bigfoot dataset
data2 <- open_bigfoot_csv(
  './data/bfro_locations.csv',
  label_col = "classification",
  popup_col = "title",
  sep = ","
)
filter_reports <- c('17240', '36759', '38287')
data2 <- data2 %>%
  filter(!grepl(paste(filter_reports, collapse = "|"), popup_col))


# Loading third dataset
data3 <- data.frame(
  lat = c(33.7490, 37.7749, 34.0522),
  lng = c(-84.3880, -122.4194, -118.2437),
  name = c("Atlanta", "San Francisco", "Los Angeles")
)



# Define UIe
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
        choices = c("Tracking Seagull's settlements" = "data1", "Following in Bigfoot's footsteps" = "data2")

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
    h3("Customization Panel"),
    p("Welcome to the customization panel, where you can tailor the visual aspects of the map to suit your preferences and data presentation needs."),
    checkboxInput("darkmode", "Dark Mode", value = FALSE),
    checkboxInput("density_toggle", "Show Data Density", value = FALSE),
    checkboxInput("cluster_toggle", "Cluster markers above (# of points):", value = TRUE),
    numericInput("cluster_numeric", label = NULL, value = 500)
  ),
  div(
    class = "leaflet-right-panel",
    fluidRow(
      column(width = 12, align = "center",
             h3("Legend")
      ),
      class = "custom-fluid-row"
    ),
    uiOutput("cardSet")
  )
)

# Define server logic
server <- function(input, output, session) {


  # Reactive expression for selected data based on dropdown selection
  selected_data <- reactive({
    switch(
      input$dropdown,
      "data1" = data1,
      "data2" = data2,
      "data3" = data3
    )
  })


  # Reactive expression for selected icon based on dropdown selection
  selected_icon <- reactive({
    switch(
      input$dropdown,
      "data1" = "crow",
      "data2" = "shoe-prints",
      "data3" = "shoe-prints"
    )
  })

  # Reactive expression for selected color palette based on dropdown selection
  color_palette <- reactive({
    switch(
      input$dropdown,
      "data1" =  c(
        "Argenté" = "lightgray",
        "Marin" = "lightblue",
        "Brun" = "brown"
      ),
      "data2" = c(
        "Class A" = "red",
        "Class B" = "orange",
        "Class C" = "darkgreen"
      ),
      "data3" = c(
        "Class A" = "#FF0000",
        "Class B" = "#FFFF00",
        "Class C" = "#008000"
      )
    )
  })


  # Reactive expression for selected color palette based on dropdown selection
  legend_images <- reactive({
    switch(
      input$dropdown,
      "data1" =  c(
        "Argenté" = "goeland_argente.jpg",
        "Marin" = "goeland_marin.jpg",
        "Brun" = "goeland_brun.jpg"
      ),
      "data2" = c(
        "Class A" = "classA.png",
        # Red
        "Class B" = "classB.png",
        # Orange
        "Class C" = "classC.png"
      ),
      # Dark Green
      "data3" = c(
        "Class A" = "#FF0000",
        # Red
        "Class B" = "#FFFF00",
        # Yellow
        "Class C" = "#008000"
      )  # Green
    )
  })

  legend_text <- reactive({
    switch(
      input$dropdown,
      "data1" =  c(
        "Argenté" = "The European Herring Gull (Larus argentatus) is a medium-sized species of seabirds",
        "Marin" = "The great black-backed gull (Larus marinus) is the largest member of the gull family",
        "Brun" = "The lesser black-backed gull (Larus fuscus) is a large gull that breeds on the Atlantic coasts of Europe"
      ),
      "data2" = c(
        "Class A" = "Clear sightings in circumstances where misinterpretation or misidentification of other animals can be ruled out with greater confidence",
        # Red
        "Class B" = "Incidents where a possible sasquatch was observed at a great distance or in poor lighting conditions",
        # Orange
        "Class C" = "Most second-hand reports, and any third-hand reports, or stories with an untraceable sources"
      ),
      # Dark Green
      "data3" = c(
        "Class A" = "#FF0000",
        # Red
        "Class B" = "#FFFF00",
        # Yellow
        "Class C" = "#008000"
      )  # Green
    )
  })


  # Legend
  output$cardSet <- renderUI({
    labels <- names(color_palette())
    colors <- color_palette()
    image_urls <- legend_images()
    legend_text <- legend_text()

    card_set_html <- generate_card_set(labels, colors, image_urls, legend_text)

    HTML(card_set_html)
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
  observeEvent(list(input$annee_slider,input$cluster_toggle, input$cluster_numeric), {
    if (length(filtered_data() > 0 )) {


      # Get the filtered data
      filtered_data <- filtered_data()

      # Filter the unique values from the label_col column
      unique_labels <- unique(filtered_data$label_col)

      # Color palette base on label present in the data
      color_pal <- color_palette()[unique_labels]



      leafletProxy("map") %>%
        clearGroup("marker_map") %>%
        addAwesomeMarkers(data = filtered_data,
                          label = ~as.character(label_col),
                          popup = ~as.character(popup_col),
                          clusterOptions = if(input$cluster_toggle & nrow(filtered_data())> input$cluster_numeric){markerClusterOptions()} else NULL,
                          icon = ~awesomeIcons(icon = selected_icon(), library = "fa", markerColor = customMarkerColor(label_col, color = color_pal)),
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
