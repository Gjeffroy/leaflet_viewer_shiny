library(shiny)

# Sourcing functions
source('./R/data.R')
source('./R/app.R')


# Loading Goeland dataset
data1 <- open_goeland_csv(
  './data/sterilisations-de-nids-de-goelands-ville-de-lorient.csv',
  selected_columns = c(
    "nid_support"
  ),
  sep = ";"
)


# Loading Bigfoot dataset
data2 <- open_bigfoot_csv(
  './data/bfro_locations.csv',
  selected_columns = c(
  ),
  sep = ","
)

# Loading third dataset
data3 <- data.frame(
  lat = c(33.7490, 37.7749, 34.0522),
  lng = c(-84.3880, -122.4194, -118.2437),
  name = c("Atlanta", "San Francisco", "Los Angeles")
)

# Run app
shiny::shinyApp(ui, server)
