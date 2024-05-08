library(shiny)

# Sourcing functions
source('./app/data.R')
source('./app/app.R')
source('./app/helpers.R')

# Run app
shiny::shinyApp(ui, server)
